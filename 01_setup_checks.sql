-- 01_setup_checks.sql
-- Purpose: confirm both CSV files loaded correctly and review table structure.
-- Tables: opportunity_data (expected 5,733 rows) and learner_data (expected 1,979 rows).
-- Both tables were imported with every column as text.
-- Tip: the Supabase SQL editor only shows the result of the LAST statement,
-- so run each query on its own.

-- Row counts (compare with the row counts in the source CSV files)
SELECT COUNT(*) FROM opportunity_data;   -- expected 5733
SELECT COUNT(*) FROM learner_data;       -- expected 1979

-- Column names and data types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'opportunity_data'
ORDER BY ordinal_position;               -- 33 columns, all text

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'learner_data'
ORDER BY ordinal_position;               -- 256 columns, all text

-- Learner Data columns that have placeholder names (created during import)
SELECT COUNT(*)
FROM information_schema.columns
WHERE table_name = 'learner_data' AND column_name LIKE 'col\_%';   -- 212

-- Sample rows
SELECT * FROM opportunity_data LIMIT 10;
SELECT application_id, status, apply_date, category FROM learner_data LIMIT 10;

-- Note: column names with capital letters (for example "Reward") must be double-quoted.
