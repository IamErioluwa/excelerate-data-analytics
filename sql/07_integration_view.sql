-- category-level view, since no record-level key exists

-- TRIM matters: hidden whitespace made a plain join return nothing
DROP VIEW IF EXISTS integrated_category_summary;

CREATE VIEW integrated_category_summary AS
SELECT
  o.cat AS category,
  o.total_opportunities,
  o.avg_opportunity_fee,
  l.total_learner_records,
  l.learner_applications,
  l.learner_completions
FROM (
  SELECT TRIM(category) AS cat,
         COUNT(DISTINCT opportunity_id) AS total_opportunities,
         ROUND(AVG(fee), 2) AS avg_opportunity_fee
  FROM opportunity_data_clean
  GROUP BY TRIM(category)
) o
LEFT JOIN (
  SELECT TRIM(category) AS cat,
         COUNT(*) AS total_learner_records,
         COUNT(DISTINCT application_id) AS learner_applications,
         COUNT(completion_date) AS learner_completions
  FROM learner_data_clean
  GROUP BY TRIM(category)
) l ON o.cat = l.cat
ORDER BY o.total_opportunities DESC;

SELECT * FROM integrated_category_summary;
