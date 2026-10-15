-- 07_integration_view.sql
-- Purpose: category-level integration of the two cleaned tables.
-- No reliable record-level key exists (see 04), so each table is summarised by
-- TRIM(category) first and the two summaries are then joined.
-- TRIM matters: hidden whitespace made a plain equality join return nothing.
-- Joining the raw tables directly would also multiply rows, because category is not unique.
-- Run after 05 and 06.

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
-- Expected: Internship 1591 opportunities / 184 learner records; Career 1087 / 129;
-- Competition 734 / 66; Course 631 / 68; Event 621 / 78; Engagement 459 / 44;
-- Masterclass 400 / 41; JobSimulation 198 / 18.
-- learner_applications and learner_completions are 0 in every category: all 203 usable
-- application IDs and all 162 completion dates sit in learner records with no category.
