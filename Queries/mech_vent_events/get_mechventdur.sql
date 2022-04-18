-- ------------------------------------------------------------------
-- Code based on: https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/concepts/durations
-- Description: This query provides a useful set information about the duration of each mechanical
-- ventilation.
-- Extracted number of rows: 38045
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.mechventdur;
CREATE TABLE mortpred.mechventdur as


with vd0 as
(
  select
    mv.icustay_id
    -- this carries over the previous charttime which had a mechanical ventilation event
    , case
        when mv.MechVent=1 then
          LAG(mv.CHARTTIME, 1) OVER (partition by mv.icustay_id, mv.MechVent order by mv.charttime)
        else null
      end as charttime_lag
    , mv.charttime
    , mv.MechVent
    , mv.OxygenTherapy
    , mv.Extubated
    , mv.SelfExtubated
  from mortpred.mechvent mv
)
, vd1 as
(
  select
      icustay_id
      , charttime_lag
      , charttime
      , MechVent
      , OxygenTherapy
      , Extubated
      , SelfExtubated

      -- if this is a mechanical ventilation event, we calculate the time since the last event
      , case
          -- if the current observation indicates mechanical ventilation is present
          -- calculate the time since the last vent event
          when MechVent=1 then
            (((DATE_PART('day', CHARTTIME - charttime_lag)) * 24 + DATE_PART('hour', CHARTTIME - charttime_lag)) * 60 + DATE_PART('minute', CHARTTIME - charttime_lag))/60
          else null
        end as ventduration

      , LAG(Extubated,1)
      OVER
      (
      partition by icustay_id, case when MechVent=1 or Extubated=1 then 1 else 0 end
      order by charttime
      ) as ExtubatedLag

      -- now we determine if the current mech vent event is a "new", i.e. they've just been intubated
      , case
        -- if there is an extubation flag, we mark any subsequent ventilation as a new ventilation event
          --when Extubated = 1 then 0 -- extubation is *not* a new ventilation event, the *subsequent* row is
          when
            LAG(Extubated,1)
            OVER
            (
            partition by icustay_id, case when MechVent=1 or Extubated=1 then 1 else 0 end
            order by charttime
            )
            = 1 then 1
          -- if patient has initiated oxygen therapy, and is not currently vented, start a newvent
          when MechVent = 0 and OxygenTherapy = 1 then 1
            -- if there is less than 8 hours between vent settings, we do not treat this as a new ventilation event
          when CHARTTIME > charttime_lag + INTERVAL '8 hours'
            then 1
        else 0
        end as newvent
  -- use the staging table with only vent settings from chart events
  FROM vd0 ventsettings
)
, vd2 as
(
  select vd1.*
  -- create a cumulative sum of the instances of new ventilation
  -- this results in a monotonic integer assigned to each instance of ventilation
  , case when MechVent=1 or Extubated = 1 then
      SUM( newvent )
      OVER ( partition by icustay_id order by charttime )
    else null end
    as ventnum
  --- now we convert CHARTTIME of ventilator settings into durations
  from vd1
)
-- create the durations for each mechanical ventilation instance
select icustay_id
  -- regenerate ventnum so it's sequential
  , ROW_NUMBER() over (partition by icustay_id order by ventnum) as ventnum
  , min(charttime) as starttime
  , max(charttime) as endtime
  , (((DATE_PART('day', max(charttime) - min(charttime))) * 24 + DATE_PART('hour', max(charttime) - min(charttime))) * 60 + DATE_PART('minute', max(charttime) - min(charttime)))/60 AS duration_hours
from vd2
group by icustay_id, vd2.ventnum
having min(charttime) != max(charttime)
-- patient had to be mechanically ventilated at least once
-- i.e. max(mechvent) should be 1
-- this excludes a frequent situation of NIV/oxygen before intub
-- in these cases, ventnum=0 and max(mechvent)=0, so they are ignored
and max(mechvent) = 1
order by icustay_id, ventnum