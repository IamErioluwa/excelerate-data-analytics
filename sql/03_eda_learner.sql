-- first look at learner_data

SELECT status, COUNT(*) FROM learner_data GROUP BY status ORDER BY COUNT(*) DESC;

SELECT from_where_did_you_hear_about_us, COUNT(*)
FROM learner_data
GROUP BY from_where_did_you_hear_about_us
ORDER BY COUNT(*) DESC
LIMIT 15;

SELECT
  COUNT(*) AS total,
  COUNT(completion_date) AS completed,
  COUNT(dropped_out_date) AS dropped_out,
  COUNT(withdraw_date) AS withdrawn,
  COUNT(not_started_date) AS not_started
FROM learner_data;

SELECT COUNT(*) FROM learner_data
WHERE dropped_out_date IS NOT NULL AND withdraw_date IS NOT NULL;

SELECT payment_status, COUNT(*) FROM learner_data GROUP BY payment_status ORDER BY COUNT(*) DESC;

SELECT apply_date, created_at, completion_date FROM learner_data WHERE apply_date IS NOT NULL LIMIT 5;

SELECT completion_date, dropped_out_date, withdraw_date, not_started_date, accept_reject_date, reward_awarded_date
FROM learner_data
WHERE completion_date IS NOT NULL OR dropped_out_date IS NOT NULL OR withdraw_date IS NOT NULL
LIMIT 5;

SELECT application_id, COUNT(*)
FROM learner_data
GROUP BY application_id
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 10;

SELECT COUNT(DISTINCT application_id) FROM learner_data WHERE application_id IS NOT NULL;

SELECT COUNT(*) FROM learner_data WHERE apply_date::date > CURRENT_DATE;
