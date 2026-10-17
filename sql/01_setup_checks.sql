-- load checks: row counts and column types

SELECT COUNT(*) FROM opportunity_data;
SELECT COUNT(*) FROM learner_data;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'opportunity_data'
ORDER BY ordinal_position;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'learner_data'
ORDER BY ordinal_position;

SELECT COUNT(*)
FROM information_schema.columns
WHERE table_name = 'learner_data' AND column_name LIKE 'col\_%';

SELECT * FROM opportunity_data LIMIT 10;
SELECT application_id, status, apply_date, category FROM learner_data LIMIT 10;
