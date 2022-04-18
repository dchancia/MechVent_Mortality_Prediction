-- ------------------------------------------------------------------
-- Description: This query filters the mechanical ventilation events by selecting 
-- the first mechanical ventilation event of the ICU stay that lasted at least 24h.
-- Extracted number of rows: 11742
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.mechventcohort;
CREATE TABLE mortpred.mechventcohort as

SELECT 

-- required ids
mv.icustay_id, mv.starttime, mv.duration_hours

FROM mortpred.mechventdur mv
WHERE mv.ventnum=1
AND mv.duration_hours>=24
ORDER BY mv.icustay_id;