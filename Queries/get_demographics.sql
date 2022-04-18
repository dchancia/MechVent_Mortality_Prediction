-- ------------------------------------------------------------------
-- Code based on: https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/concepts/demographics
-- Description: This query provides a useful set information about the patients demographics.
-- Extracted number of rows: 61532
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.demographics;
CREATE TABLE mortpred.demographics as


SELECT 

-- required ids
ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient gender
, pat.gender

-- patient admission age
, DATE_PART('year', ie.intime) - DATE_PART('year', pat.dob) as admission_age

FROM mimiciii.icustays ie
INNER JOIN mimiciii.patients pat
  ON ie.subject_id = pat.subject_id
ORDER BY ie.subject_id;