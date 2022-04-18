-- ------------------------------------------------------------------
-- Description: This query provides a useful set information about the hours from ICU admission
-- to mechanical ventilation initiation.
-- Extracted number of rows: 11742
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.icutomechvent;
CREATE TABLE mortpred.icutomechvent as

SELECT 

-- required ids
ie.icustay_id

-- patient time from hospitalization to ICU admission
, CASE 
	WHEN (DATE_PART('day', mv.starttime - ie.intime)) * 24 + DATE_PART('hour', mv.starttime - ie.intime) >= 0 THEN
		(DATE_PART('day', mv.starttime - ie.intime)) * 24 + DATE_PART('hour', mv.starttime - ie.intime)
	ELSE 0
	END AS hours_icu_to_mv


FROM mimiciii.icustays ie
INNER JOIN mortpred.mechventcohort mv
  ON ie.icustay_id = mv.icustay_id
ORDER BY ie.icustay_id;