-- ------------------------------------------------------------------
-- Code based on: https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/concepts/demographics
-- Description: This query provides a useful set information about the hours from hospitalization 
-- to when the patient was transferred to ICU.
-- Extracted number of rows: 61532
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.hosptoicu;
CREATE TABLE mortpred.hosptoicu as

SELECT 

-- required ids
ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient time from hospitalization to ICU admission
, CASE 
	WHEN (DATE_PART('day', ie.intime - adm.admittime)) * 24 + DATE_PART('hour', ie.intime - adm.admittime) >= 0 THEN
		(DATE_PART('day', ie.intime - adm.admittime)) * 24 + DATE_PART('hour', ie.intime - adm.admittime)
	ELSE 0
	END AS hours_hosp_to_icu


FROM mimiciii.icustays ie
INNER JOIN mimiciii.admissions adm
  ON ie.hadm_id = adm.hadm_id
ORDER BY ie.subject_id;