-- ------------------------------------------------------------------
-- Description: This query provides a useful set information about the patients 30-day mortality.
-- Extracted number of rows: 11742
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.mortality;
CREATE TABLE mortpred.mortality as

SELECT 

-- required ids
ie.subject_id, mv.icustay_id

-- patient mortality
, pat.dod, pat.expire_flag

, (CASE	WHEN pat.dod IS NOT NULL AND (DATE_PART('day', pat.dod - mv.starttime)) <= 30 THEN 1 ELSE 0 END) as mech_expire_flag 

FROM mortpred.mechventcohort mv
  LEFT JOIN mimiciii.icustays ie
    ON mv.icustay_id = ie.icustay_id 
  LEFT JOIN mimiciii.patients pat
    ON pat.subject_id = ie.subject_id
ORDER BY ie.subject_id;

