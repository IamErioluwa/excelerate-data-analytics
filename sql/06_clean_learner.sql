-- builds learner_data_clean. no rows removed, 1979 in and 1979 out.

DROP TABLE IF EXISTS learner_data_clean;

CREATE TABLE learner_data_clean AS
SELECT * FROM learner_data;

UPDATE learner_data_clean SET from_where_did_you_hear_about_us = NULL
  WHERE upper(trim(from_where_did_you_hear_about_us)) = 'NULL';
UPDATE learner_data_clean SET from_where_did_you_hear_about_us = 'Social Media'
  WHERE lower(trim(from_where_did_you_hear_about_us)) = 'social media';
UPDATE learner_data_clean SET from_where_did_you_hear_about_us = 'My Friend Or Relative'
  WHERE lower(trim(from_where_did_you_hear_about_us)) IN ('my friend or relative','my friend/relative');
UPDATE learner_data_clean SET from_where_did_you_hear_about_us = 'Illinois Institute of Technology'
  WHERE lower(trim(from_where_did_you_hear_about_us)) IN ('illinois institute of technology','illinois tech');
UPDATE learner_data_clean SET from_where_did_you_hear_about_us = 'Other'
  WHERE lower(trim(from_where_did_you_hear_about_us)) = 'others';

-- test and placeholder values treated as missing
UPDATE learner_data_clean SET application_id = NULL
  WHERE lower(trim(application_id)) IN ('testing','12345','123456','app12345','9876543','31231313','64654','12331')
     OR trim(application_id) = 'I want to improve My knowledge';

UPDATE learner_data_clean SET category = NULL WHERE upper(trim(category)) = 'NULL';

-- text 'NULL' to real NULL
UPDATE learner_data_clean SET apply_date = NULL WHERE upper(trim(apply_date)) = 'NULL';
UPDATE learner_data_clean SET created_at = NULL WHERE upper(trim(created_at)) = 'NULL';
UPDATE learner_data_clean SET modified_at = NULL WHERE upper(trim(modified_at)) = 'NULL';
UPDATE learner_data_clean SET completion_date = NULL WHERE upper(trim(completion_date)) = 'NULL';
UPDATE learner_data_clean SET dropped_out_date = NULL WHERE upper(trim(dropped_out_date)) = 'NULL';
UPDATE learner_data_clean SET withdraw_date = NULL WHERE upper(trim(withdraw_date)) = 'NULL';
UPDATE learner_data_clean SET not_started_date = NULL WHERE upper(trim(not_started_date)) = 'NULL';
UPDATE learner_data_clean SET accept_reject_date = NULL WHERE upper(trim(accept_reject_date)) = 'NULL';
UPDATE learner_data_clean SET reward_awarded_date = NULL WHERE upper(trim(reward_awarded_date)) = 'NULL';
UPDATE learner_data_clean SET fee = NULL WHERE upper(trim(fee)) = 'NULL';
UPDATE learner_data_clean SET amount_to_be_paid = NULL WHERE upper(trim(amount_to_be_paid)) = 'NULL';

-- should be 1979
SELECT COUNT(*) FROM learner_data_clean;

-- stage 2
-- 1 bad value in dropped_out_date, 43 in accept_reject_date
UPDATE learner_data_clean SET dropped_out_date = NULL
  WHERE dropped_out_date IS NOT NULL AND dropped_out_date !~ '^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$';
UPDATE learner_data_clean SET accept_reject_date = NULL
  WHERE accept_reject_date IS NOT NULL AND accept_reject_date !~ '^[0-9]+(\.[0-9]+)?([eE][+-]?[0-9]+)?$';

ALTER TABLE learner_data_clean ALTER COLUMN apply_date TYPE timestamp USING apply_date::timestamp;
ALTER TABLE learner_data_clean ALTER COLUMN created_at TYPE timestamp USING to_timestamp(created_at::numeric::bigint / 1000);
ALTER TABLE learner_data_clean ALTER COLUMN modified_at TYPE timestamp USING to_timestamp(modified_at::numeric::bigint / 1000);
ALTER TABLE learner_data_clean ALTER COLUMN completion_date TYPE timestamp USING to_timestamp(completion_date::numeric::bigint / 1000);
ALTER TABLE learner_data_clean ALTER COLUMN dropped_out_date TYPE timestamp USING to_timestamp(dropped_out_date::numeric::bigint / 1000);
ALTER TABLE learner_data_clean ALTER COLUMN withdraw_date TYPE timestamp USING to_timestamp(withdraw_date::numeric::bigint / 1000);
ALTER TABLE learner_data_clean ALTER COLUMN not_started_date TYPE timestamp USING to_timestamp(not_started_date::numeric::bigint / 1000);
ALTER TABLE learner_data_clean ALTER COLUMN accept_reject_date TYPE timestamp USING to_timestamp(accept_reject_date::numeric::bigint / 1000);
ALTER TABLE learner_data_clean ALTER COLUMN reward_awarded_date TYPE timestamp USING to_timestamp(reward_awarded_date::numeric::bigint / 1000);

ALTER TABLE learner_data_clean ALTER COLUMN fee TYPE numeric USING fee::numeric;
ALTER TABLE learner_data_clean ALTER COLUMN amount_to_be_paid TYPE numeric USING amount_to_be_paid::numeric;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'learner_data_clean'
  AND column_name IN ('apply_date','created_at','modified_at','completion_date','dropped_out_date',
                      'withdraw_date','not_started_date','accept_reject_date','reward_awarded_date',
                      'fee','amount_to_be_paid');

-- stage 3
SELECT COUNT(amount_to_be_paid) AS filled, MIN(amount_to_be_paid) AS min_val, MAX(amount_to_be_paid) AS max_val,
       COUNT(*) FILTER (WHERE amount_to_be_paid > 10000) AS suspiciously_large
FROM learner_data_clean;

-- 10,000 is my cut-off, the next largest real values are 2,000 and under
UPDATE learner_data_clean SET amount_to_be_paid = NULL WHERE amount_to_be_paid > 10000;

SELECT payment_status, COUNT(*) AS records, SUM(amount_to_be_paid) AS total_amount
FROM learner_data_clean
GROUP BY payment_status
ORDER BY records DESC;
