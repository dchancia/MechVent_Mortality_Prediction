-- ------------------------------------------------------------------
-- Description: This query provides a useful set information about the patients severity scores.
-- Extracted number of rows: 61532
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.sevscores;
CREATE TABLE mortpred.sevscores as

SELECT 

-- required ids
oa.icustay_id

-- patient severity scores
, oa.oasis, lo.lods, sa.sapsii, so.sofa


FROM mortpred.oasis oa
INNER JOIN mortpred.lods lo
  ON oa.icustay_id = lo.icustay_id
INNER JOIN mortpred.saps2 sa
  ON oa.icustay_id = sa.icustay_id
INNER JOIN mortpred.sofa so
  ON oa.icustay_id = so.icustay_id
ORDER BY oa.icustay_id;