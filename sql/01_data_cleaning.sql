-- 1. Standardise text 'NULL' to actual NULL
UPDATE opportunity_data_clean 
SET category = NULL WHERE category = 'NULL';

UPDATE learner_data_clean 
SET category = NULL WHERE category = 'null';

-- 2. Standardise opportunity locations
UPDATE opportunity_data_clean
SET location = 'Virtual'
WHERE location IN ('virtual', 'vitrual');

UPDATE opportunity_data_clean
SET location = 'Work From Home'
WHERE location IN ('WFM', 'wfm');

-- 3. Standardise lead sources
UPDATE learner_data_clean
SET from_where_did_you_hear_about_us = 'Social Media'
WHERE from_where_did_you_hear_about_us = 'social Media';

UPDATE learner_data_clean
SET from_where_did_you_hear_about_us = 'My Friend Or Relative'
WHERE from_where_did_you_hear_about_us = 'My Friend/Relative';

UPDATE learner_data_clean
SET from_where_did_you_hear_about_us = 'Illinois Institute of Technology'
WHERE from_where_did_you_hear_about_us = 'Illinois Tech';

UPDATE learner_data_clean
SET from_where_did_you_hear_about_us = 'Other'
WHERE from_where_did_you_hear_about_us = 'Others';

-- 4. Clean impossible payment values
UPDATE learner_data_clean
SET amount_to_be_paid = NULL
WHERE amount_to_be_paid::numeric > 10000;

-- 5. Fix epoch date fields
-- Note: Requires changing column type to timestamp first
UPDATE opportunity_data_clean
SET start_date = to_timestamp(start_date::numeric::bigint / 1000)
WHERE start_date IS NOT NULL;