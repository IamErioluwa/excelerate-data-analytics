-- 02_eda_opportunity.sql
-- Purpose: explore Opportunity Data before cleaning. Run each query separately.

-- Categories and counts
SELECT category, COUNT(*) AS total
FROM opportunity_data
GROUP BY category
ORDER BY total DESC;

-- Duplicate check on opportunity_id (returns no rows: the id is unique)
SELECT opportunity_id, COUNT(*)
FROM opportunity_data
GROUP BY opportunity_id
HAVING COUNT(*) > 1;

-- Missing values in key fields
SELECT
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
  COUNT(*) FILTER (WHERE "Reward" IS NULL) AS missing_reward,
  COUNT(*) FILTER (WHERE name IS NULL) AS missing_name,
  COUNT(*) FILTER (WHERE fee IS NULL) AS missing_fee
FROM opportunity_data;

-- Reward holds embedded JSON, not an amount
SELECT DISTINCT "Reward" FROM opportunity_data ORDER BY "Reward" LIMIT 30;

-- Other columns with the same JSON reference pattern
SELECT "CareerAddOn", "Cohort", "DropoutTransaction", "Eligibility",
       "NotStartedTransaction", "Panellist", "Testimonial", tracking_questions
FROM opportunity_data
WHERE "CareerAddOn" IS NOT NULL
LIMIT 5;

-- Plain-looking fields
SELECT DISTINCT fee, duration, duration_type, currency_type FROM opportunity_data LIMIT 15;

SELECT duration_type, COUNT(*) FROM opportunity_data GROUP BY duration_type ORDER BY COUNT(*) DESC;
SELECT currency_type, COUNT(*) FROM opportunity_data GROUP BY currency_type ORDER BY COUNT(*) DESC;
SELECT location, COUNT(*) FROM opportunity_data GROUP BY location ORDER BY COUNT(*) DESC LIMIT 15;
SELECT is_archived, COUNT(*) FROM opportunity_data GROUP BY is_archived;
SELECT is_auto_approve, COUNT(*) FROM opportunity_data GROUP BY is_auto_approve;

-- Date fields are millisecond epoch timestamps stored as text
SELECT created_at, modified_at, last_date_to_apply FROM opportunity_data LIMIT 5;

-- Literal text 'NULL' hiding in columns (different from a true NULL)
SELECT
  COUNT(*) FILTER (WHERE upper(trim(fee)) = 'NULL') AS fee_null_text,
  COUNT(*) FILTER (WHERE upper(trim(created_at)) = 'NULL') AS created_null_text,
  COUNT(*) FILTER (WHERE upper(trim(modified_at)) = 'NULL') AS modified_null_text,
  COUNT(*) FILTER (WHERE upper(trim(last_date_to_apply)) = 'NULL') AS last_date_null_text
FROM opportunity_data;

-- Corrupted rows: JSON fragments sitting in fields that should hold plain values.
-- Text 'NULL' is excluded. An early version that did not exclude it over-counted
-- hundreds of rows; the true number of corrupted rows is 6.
SELECT
  COUNT(*) FILTER (WHERE fee !~ '^[0-9]+(\.[0-9]+)?$' AND fee IS NOT NULL AND upper(trim(fee)) != 'NULL') AS bad_fee,
  COUNT(*) FILTER (WHERE currency_type NOT IN ('USD','INR','EUR','EURO') AND currency_type IS NOT NULL AND upper(trim(currency_type)) != 'NULL') AS bad_currency,
  COUNT(*) FILTER (WHERE is_auto_approve NOT IN ('TRUE','FALSE') AND is_auto_approve IS NOT NULL AND upper(trim(is_auto_approve)) != 'NULL') AS bad_auto_approve,
  COUNT(*) FILTER (WHERE is_archived NOT IN ('TRUE','FALSE') AND is_archived IS NOT NULL AND upper(trim(is_archived)) != 'NULL') AS bad_archived,
  COUNT(*) FILTER (WHERE duration_type NOT IN ('day','days','week','weeks','month','months','hour','hours','minute','minutes','year','years') AND duration_type IS NOT NULL AND upper(trim(duration_type)) != 'NULL') AS bad_duration
FROM opportunity_data;
