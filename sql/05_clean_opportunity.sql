-- 05_clean_opportunity.sql
-- Purpose: build opportunity_data_clean from opportunity_data. The raw table is left untouched.
-- Run Stage 1 first, check the result, then run Stage 2.
-- Why stages: the Supabase SQL editor runs a block as one transaction, so one error
-- rolls back everything, including CREATE TABLE.

----------------------------------------------------------------------
-- STAGE 1: copy, remove corrupted rows, standardise text, fix literal 'NULL'
----------------------------------------------------------------------
DROP TABLE IF EXISTS opportunity_data_clean;

CREATE TABLE opportunity_data_clean AS
SELECT * FROM opportunity_data;

-- Remove rows where JSON fragments spilled into plain-value columns.
-- Literal text 'NULL' is excluded here (it is handled further down).
DELETE FROM opportunity_data_clean
WHERE (fee !~ '^[0-9]+(\.[0-9]+)?$' AND fee IS NOT NULL AND upper(trim(fee)) != 'NULL')
   OR (currency_type NOT IN ('USD','INR','EUR','EURO') AND currency_type IS NOT NULL AND upper(trim(currency_type)) != 'NULL')
   OR (is_auto_approve NOT IN ('TRUE','FALSE') AND is_auto_approve IS NOT NULL AND upper(trim(is_auto_approve)) != 'NULL')
   OR (is_archived NOT IN ('TRUE','FALSE') AND is_archived IS NOT NULL AND upper(trim(is_archived)) != 'NULL')
   OR (duration_type NOT IN ('day','days','week','weeks','month','months','hour','hours','minute','minutes','year','years')
       AND duration_type IS NOT NULL AND upper(trim(duration_type)) != 'NULL');

-- Location: one label per real value
UPDATE opportunity_data_clean SET location = NULL WHERE lower(trim(location)) = 'null';
UPDATE opportunity_data_clean SET location = 'Virtual' WHERE lower(trim(location)) IN ('virtual','vitrual');
UPDATE opportunity_data_clean SET location = 'Work From Home' WHERE lower(trim(location)) IN ('work from home','wfm');

-- Currency and duration units
UPDATE opportunity_data_clean SET currency_type = 'EUR' WHERE currency_type = 'EURO';
UPDATE opportunity_data_clean SET duration_type = 'days' WHERE duration_type = 'day';
UPDATE opportunity_data_clean SET duration_type = 'weeks' WHERE duration_type = 'week';
UPDATE opportunity_data_clean SET duration_type = 'months' WHERE duration_type = 'month';
UPDATE opportunity_data_clean SET duration_type = 'hours' WHERE duration_type = 'hour';
UPDATE opportunity_data_clean SET duration_type = 'minutes' WHERE duration_type = 'minute';
UPDATE opportunity_data_clean SET duration_type = 'years' WHERE duration_type IN ('year','yearssss');

-- Turn the text 'NULL' into a real NULL
UPDATE opportunity_data_clean SET fee = NULL WHERE upper(trim(fee)) = 'NULL';
UPDATE opportunity_data_clean SET currency_type = NULL WHERE upper(trim(currency_type)) = 'NULL';
UPDATE opportunity_data_clean SET is_auto_approve = NULL WHERE upper(trim(is_auto_approve)) = 'NULL';
UPDATE opportunity_data_clean SET is_archived = NULL WHERE upper(trim(is_archived)) = 'NULL';
UPDATE opportunity_data_clean SET duration_type = NULL WHERE upper(trim(duration_type)) = 'NULL';
UPDATE opportunity_data_clean SET created_at = NULL WHERE upper(trim(created_at)) = 'NULL';
UPDATE opportunity_data_clean SET modified_at = NULL WHERE upper(trim(modified_at)) = 'NULL';
UPDATE opportunity_data_clean SET last_date_to_apply = NULL WHERE upper(trim(last_date_to_apply)) = 'NULL';

-- Optional, not applied in the original run: two rows appear to have the text 'NULL' as category.
-- UPDATE opportunity_data_clean SET category = NULL WHERE upper(trim(category)) = 'NULL';

-- Check: expected 5727 rows
SELECT COUNT(*) FROM opportunity_data_clean;

----------------------------------------------------------------------
-- STAGE 2: convert data types
-- Epoch values can be stored in scientific notation (for example 1.68E+12),
-- so cast to numeric first, then bigint.
----------------------------------------------------------------------
ALTER TABLE opportunity_data_clean
  ALTER COLUMN fee TYPE numeric USING fee::numeric;

ALTER TABLE opportunity_data_clean
  ALTER COLUMN created_at TYPE timestamp USING to_timestamp(created_at::numeric::bigint / 1000);

ALTER TABLE opportunity_data_clean
  ALTER COLUMN modified_at TYPE timestamp USING to_timestamp(modified_at::numeric::bigint / 1000);

ALTER TABLE opportunity_data_clean
  ALTER COLUMN last_date_to_apply TYPE timestamp USING to_timestamp(last_date_to_apply::numeric::bigint / 1000);

ALTER TABLE opportunity_data_clean
  ALTER COLUMN is_archived TYPE boolean USING is_archived::boolean;

ALTER TABLE opportunity_data_clean
  ALTER COLUMN is_auto_approve TYPE boolean USING is_auto_approve::boolean;

-- Check the new types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'opportunity_data_clean'
  AND column_name IN ('fee','created_at','modified_at','last_date_to_apply','is_archived','is_auto_approve');
