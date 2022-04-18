-- ------------------------------------------------------------------
-- Description: This query combines all the previouskt extracted features
-- for the mortality prediction task.
-- Extracted number of rows: 10183
-- ------------------------------------------------------------------

DROP TABLE IF EXISTS mortpred.mvfeatures;
CREATE TABLE mortpred.mvfeatures as


SELECT 

-- required ids
dem.subject_id, dem.hadm_id, mv.icustay_id

-- demographics
, dem.gender, dem.admission_age

-- hospitalization event
, hicu.hours_hosp_to_icu

-- mechanical ventilation event
, icumv.hours_icu_to_mv

-- elixhauser score components
, elx.congestive_heart_failure
, elx.hypertension
, elx.diabetes_uncomplicated
, elx.diabetes_complicated
, elx.metastatic_cancer
, elx.solid_tumor
, elx.blood_loss_anemia
, elx.deficiency_anemias
, elx.peripheral_vascular
, elx.hypothyroidism
, elx.liver_disease
, elx.chronic_pulmonary
, elx.psychoses
, elx.paralysis
, elx.lymphoma
, elx.coagulopathy

-- elixhauser score
, elxs.elixhauser_vanwalraven

-- severity disease scores
, sev.oasis
, sev.lods
, sev.sapsii
, sev.sofa

-- vitals
, vt.heartrate_min
, vt.heartrate_max
, vt.heartrate_mean
, vt.sysbp_min
, vt.sysbp_max
, vt.sysbp_mean
, vt.diasbp_min
, vt.diasbp_max
, vt.diasbp_mean
, vt.meanbp_min
, vt.meanbp_max
, vt.meanbp_mean
, vt.resprate_min
, vt.resprate_max
, vt.resprate_mean
, vt.tempc_min
, vt.tempc_max
, vt.tempc_mean
, vt.spo2_min
, vt.spo2_max
, vt.spo2_mean

-- labs
, lb.albumin_min
, lb.albumin_max
, lb.bands_min
, lb.bands_max
, lb.bicarbonate_min
, lb.bicarbonate_max
, lb.creatinine_min
, lb.creatinine_max
, lb.chloride_min
, lb.chloride_max
, lb.glucose_min
, lb.glucose_max
, lb.hematocrit_min
, lb.hematocrit_max
, lb.hemoglobin_min
, lb.hemoglobin_max
, lb.lactate_min
, lb.lactate_max
, lb.platelet_min
, lb.platelet_max
, lb.potassium_min
, lb.potassium_max
, lb.sodium_min
, lb.sodium_max
, lb.bun_min
, lb.bun_max
, lb.wbc_min
, lb.wbc_max

-- mortality
, mt.mech_expire_flag

FROM mortpred.demographics dem
INNER JOIN mortpred.mechventcohort mv
  ON dem.icustay_id = mv.icustay_id
  AND (dem.admission_age >= 18 AND dem.admission_age <= 90)
INNER JOIN mortpred.hosptoicu hicu
  ON dem.subject_id = hicu.subject_id AND dem.hadm_id = hicu.hadm_id AND dem.icustay_id = hicu.icustay_id
INNER JOIN mortpred.icutomechvent icumv
  ON dem.icustay_id = icumv.icustay_id
INNER JOIN mortpred.elixhauser elx
  ON dem.subject_id = elx.subject_id AND dem.hadm_id = elx.hadm_id
INNER JOIN mortpred.elixhauserscore elxs
  ON dem.subject_id = elxs.subject_id AND dem.hadm_id = elxs.hadm_id
INNER JOIN mortpred.sevscores sev
  ON dem.icustay_id = sev.icustay_id
INNER JOIN mortpred.mechvitals vt
  ON dem.icustay_id = vt.icustay_id
INNER JOIN mortpred.mechlabs lb
  ON dem.subject_id = lb.subject_id AND dem.hadm_id = lb.hadm_id AND dem.icustay_id = lb.icustay_id
INNER JOIN mortpred.mortality mt
  ON dem.subject_id = mt.subject_id AND dem.icustay_id = mt.icustay_id
ORDER BY dem.subject_id, dem.hadm_id, mv.icustay_id;