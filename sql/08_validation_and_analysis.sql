-- before/after checks, dashboard validation and analysis queries

SELECT
  (SELECT COUNT(*) FROM opportunity_data) AS opp_before_count,
  (SELECT COUNT(*) FROM opportunity_data_clean) AS opp_after_count,
  (SELECT COUNT(DISTINCT location) FROM opportunity_data WHERE location IS NOT NULL) AS opp_location_before,
  (SELECT COUNT(DISTINCT location) FROM opportunity_data_clean WHERE location IS NOT NULL) AS opp_location_after,
  (SELECT COUNT(DISTINCT duration_type) FROM opportunity_data WHERE duration_type IS NOT NULL) AS opp_duration_before,
  (SELECT COUNT(DISTINCT duration_type) FROM opportunity_data_clean WHERE duration_type IS NOT NULL) AS opp_duration_after,
  (SELECT COUNT(*) FROM learner_data) AS learner_before_count,
  (SELECT COUNT(*) FROM learner_data_clean) AS learner_after_count,
  (SELECT COUNT(DISTINCT from_where_did_you_hear_about_us) FROM learner_data WHERE from_where_did_you_hear_about_us IS NOT NULL) AS lead_source_before,
  (SELECT COUNT(DISTINCT from_where_did_you_hear_about_us) FROM learner_data_clean WHERE from_where_did_you_hear_about_us IS NOT NULL) AS lead_source_after;

-- charts 1 to 9
SELECT 'C1 opportunities by category' AS metric, category::text AS label, COUNT(*)::numeric AS value
FROM opportunity_data_clean GROUP BY category
UNION ALL
SELECT 'C2 avg fee by category', category::text, ROUND(AVG(fee), 2)
FROM opportunity_data_clean GROUP BY category
UNION ALL
SELECT 'C3 learner records by category', TRIM(category)::text, COUNT(*)::numeric
FROM learner_data_clean GROUP BY TRIM(category)
UNION ALL
SELECT 'C4 completions by category', TRIM(category)::text, COUNT(completion_date)::numeric
FROM learner_data_clean GROUP BY TRIM(category)
UNION ALL
SELECT 'C5 applications per day (13-22 Apr 2026)', apply_date::date::text, COUNT(*)::numeric
FROM learner_data_clean
WHERE apply_date >= '2026-04-13' AND apply_date < '2026-04-23'
GROUP BY apply_date::date
UNION ALL
SELECT 'C6 applications per month (Nov 2025-Apr 2026)', TO_CHAR(DATE_TRUNC('month', apply_date), 'YYYY-MM'), COUNT(*)::numeric
FROM learner_data_clean
WHERE apply_date >= '2025-11-01' AND apply_date < '2026-05-01'
GROUP BY DATE_TRUNC('month', apply_date)
UNION ALL
SELECT 'C7 records by payment status', COALESCE(payment_status, '(null)'), COUNT(*)::numeric
FROM learner_data_clean GROUP BY payment_status
UNION ALL
SELECT 'C8 lead source', COALESCE(from_where_did_you_hear_about_us, '(null)'), COUNT(*)::numeric
FROM learner_data_clean GROUP BY from_where_did_you_hear_about_us
UNION ALL
SELECT 'C9 Q4 2025 applications', 'Oct-Dec 2025', COUNT(*)::numeric
FROM learner_data_clean WHERE apply_date >= '2025-10-01' AND apply_date < '2026-01-01'
UNION ALL
SELECT 'C9 Q1 2026 applications', 'Jan-Mar 2026', COUNT(*)::numeric
FROM learner_data_clean WHERE apply_date >= '2026-01-01' AND apply_date < '2026-04-01'
ORDER BY metric, value DESC;

SELECT COUNT(*) FROM opportunity_data_clean;
SELECT COUNT(*) FILTER (WHERE category IS NOT NULL) AS with_category,
       COUNT(*) FILTER (WHERE category IS NULL) AS no_category
FROM learner_data_clean;

-- chart 5: how close do the timestamps sit to midnight?
SELECT apply_date
FROM learner_data_clean
WHERE apply_date >= '2026-04-15' AND apply_date < '2026-04-18'
ORDER BY apply_date;

-- fees mix USD, INR and EUR
SELECT currency_type, COUNT(*) AS total_opportunities,
       ROUND(AVG(fee), 2) AS avg_fee, MIN(fee) AS min_fee, MAX(fee) AS max_fee
FROM opportunity_data_clean
WHERE fee IS NOT NULL
GROUP BY currency_type;

SELECT DATE_TRUNC('month', apply_date) AS application_month, COUNT(*) AS total_applications
FROM learner_data_clean
WHERE apply_date IS NOT NULL
GROUP BY application_month
ORDER BY application_month;

SELECT COUNT(*) AS total_records,
       COUNT(completion_date) AS completed,
       COUNT(dropped_out_date) AS dropped_out,
       COUNT(withdraw_date) AS withdrawn,
       COUNT(not_started_date) AS not_started
FROM learner_data_clean;

SELECT from_where_did_you_hear_about_us AS lead_source, COUNT(*) AS total
FROM learner_data_clean
GROUP BY from_where_did_you_hear_about_us
ORDER BY total DESC;

SELECT q4_2025, q1_2026,
       ROUND((q1_2026 - q4_2025) * 100.0 / q4_2025, 1) AS pct_change
FROM (
  SELECT COUNT(*) FILTER (WHERE apply_date >= '2025-10-01' AND apply_date < '2026-01-01') AS q4_2025,
         COUNT(*) FILTER (WHERE apply_date >= '2026-01-01' AND apply_date < '2026-04-01') AS q1_2026
  FROM learner_data_clean
) t;
