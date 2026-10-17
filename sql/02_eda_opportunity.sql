-- first look at opportunity_data

SELECT category, COUNT(*) AS total
FROM opportunity_data
GROUP BY category
ORDER BY total DESC;

SELECT opportunity_id, COUNT(*)
FROM opportunity_data
GROUP BY opportunity_id
HAVING COUNT(*) > 1;

SELECT
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE category IS NULL) AS missing_category,
  COUNT(*) FILTER (WHERE "Reward" IS NULL) AS missing_reward,
  COUNT(*) FILTER (WHERE name IS NULL) AS missing_name,
  COUNT(*) FILTER (WHERE fee IS NULL) AS missing_fee
FROM opportunity_data;

SELECT DISTINCT "Reward" FROM opportunity_data ORDER BY "Reward" LIMIT 30;

SELECT "CareerAddOn", "Cohort", "DropoutTransaction", "Eligibility",
       "NotStartedTransaction", "Panellist", "Testimonial", tracking_questions
FROM opportunity_data
WHERE "CareerAddOn" IS NOT NULL
LIMIT 5;

SELECT DISTINCT fee, duration, duration_type, currency_type FROM opportunity_data LIMIT 15;

SELECT duration_type, COUNT(*) FROM opportunity_data GROUP BY duration_type ORDER BY COUNT(*) DESC;
SELECT currency_type, COUNT(*) FROM opportunity_data GROUP BY currency_type ORDER BY COUNT(*) DESC;
SELECT location, COUNT(*) FROM opportunity_data GROUP BY location ORDER BY COUNT(*) DESC LIMIT 15;
SELECT is_archived, COUNT(*) FROM opportunity_data GROUP BY is_archived;
SELECT is_auto_approve, COUNT(*) FROM opportunity_data GROUP BY is_auto_approve;

SELECT created_at, modified_at, last_date_to_apply FROM opportunity_data LIMIT 5;

SELECT
  COUNT(*) FILTER (WHERE upper(trim(fee)) = 'NULL') AS fee_null_text,
  COUNT(*) FILTER (WHERE upper(trim(created_at)) = 'NULL') AS created_null_text,
  COUNT(*) FILTER (WHERE upper(trim(modified_at)) = 'NULL') AS modified_null_text,
  COUNT(*) FILTER (WHERE upper(trim(last_date_to_apply)) = 'NULL') AS last_date_null_text
FROM opportunity_data;

-- 6 corrupted rows once text 'NULL' is excluded
SELECT
  COUNT(*) FILTER (WHERE fee !~ '^[0-9]+(\.[0-9]+)?$' AND fee IS NOT NULL AND upper(trim(fee)) != 'NULL') AS bad_fee,
  COUNT(*) FILTER (WHERE currency_type NOT IN ('USD','INR','EUR','EURO') AND currency_type IS NOT NULL AND upper(trim(currency_type)) != 'NULL') AS bad_currency,
  COUNT(*) FILTER (WHERE is_auto_approve NOT IN ('TRUE','FALSE') AND is_auto_approve IS NOT NULL AND upper(trim(is_auto_approve)) != 'NULL') AS bad_auto_approve,
  COUNT(*) FILTER (WHERE is_archived NOT IN ('TRUE','FALSE') AND is_archived IS NOT NULL AND upper(trim(is_archived)) != 'NULL') AS bad_archived,
  COUNT(*) FILTER (WHERE duration_type NOT IN ('day','days','week','weeks','month','months','hour','hours','minute','minutes','year','years') AND duration_type IS NOT NULL AND upper(trim(duration_type)) != 'NULL') AS bad_duration
FROM opportunity_data;
