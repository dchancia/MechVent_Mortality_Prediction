-- ------------------------------------------------------------------
-- Code taken from: https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/concepts
-- Description: This query provides a useful set information about the patients echodata.
-- Extracted number of rows: 61532
-- ------------------------------------------------------------------


DROP TABLE IF EXISTS mortpred.echodata;
CREATE TABLE mortpred.echodata as

-- This code extracts structured data from echocardiographies
-- You can join it to the text notes using ROW_ID
-- Just note that ROW_ID will differ across versions of MIMIC-III.

select ROW_ID
  , subject_id, hadm_id
  , chartdate

  -- charttime is always null for echoes..
  -- however, the time is available in the echo text, e.g.:
  -- , substring(ne.text, 'Date/Time: [\[\]0-9*-]+ at ([0-9:]+)') as TIMESTAMP
  -- we can therefore impute it and re-create charttime
  , PARSE_DATETIME
  (
      '%Y-%m-%d%H:%M:%S',
      TO_CHAR(chartdate, 'YYYY-MM-DD')
      || REGEXP_MATCH(ne.text, 'Date/Time: .+? at ([0-9]+:[0-9]{2})')
   ) AS charttime

  -- explanation of below substring:
  --  'Indication: ' - matched verbatim
  --  (.*?) - match any character
  --  \n - the end of the line
  -- substring only returns the item in ()s
  -- note: the '?' makes it non-greedy. if you exclude it, it matches until it reaches the *last* \n

  , REGEXP_MATCH(ne.text, 'Indication: (.*?)\n') as Indication

  -- sometimes numeric values contain de-id text, e.g. [** Numeric Identifier **]
  -- this removes that text
  , cast(REGEXP_MATCH(ne.text, 'Height: \\x28in\\x29 ([0-9]+)') as numeric) as Height
  , cast(REGEXP_MATCH(ne.text, 'Weight \\x28lb\\x29: ([0-9]+)\n') as numeric) as Weight
  , cast(REGEXP_MATCH(ne.text, 'BSA \\x28m2\\x29: ([0-9]+) m2\n') as numeric) as BSA -- ends in 'm2'
  , REGEXP_MATCH(ne.text, 'BP \\x28mm Hg\\x29: (.+)\n') as BP -- Sys/Dias
  , cast(REGEXP_MATCH(ne.text, 'BP \\x28mm Hg\\x29: ([0-9]+)/[0-9]+?\n') as numeric) as BPSys -- first part of fraction
  , cast(REGEXP_MATCH(ne.text, 'BP \\x28mm Hg\\x29: [0-9]+/([0-9]+?)\n') as numeric) as BPDias -- second part of fraction
  , cast(REGEXP_MATCH(ne.text, 'HR \\x28bpm\\x29: ([0-9]+?)\n') as numeric) as HR

  , REGEXP_MATCH(ne.text, 'Status: (.*?)\n') as Status
  , REGEXP_MATCH(ne.text, 'Test: (.*?)\n') as Test
  , REGEXP_MATCH(ne.text, 'Doppler: (.*?)\n') as Doppler
  , REGEXP_MATCH(ne.text, 'Contrast: (.*?)\n') as Contrast
  , REGEXP_MATCH(ne.text, 'Technical Quality: (.*?)\n') as TechnicalQuality
FROM mimiciii.noteevents ne
where category = 'Echo';