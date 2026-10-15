-- 04_join_investigation.sql
-- Purpose: look for a field that links a learner to a specific opportunity.
-- Result: no reliable record-level key exists. Every apparent match below was
-- zero or a false positive. Run each query separately.

-- relation_id: only a few learner rows have a value
SELECT COUNT(*) FROM learner_data WHERE relation_id IS NOT NULL;      -- 38

SELECT COUNT(*) FROM learner_data l
WHERE EXISTS (SELECT 1 FROM opportunity_data o WHERE o.opportunity_id = l.relation_id);   -- 0

-- relation_id codes against every embedded JSON column in Opportunity Data
SELECT COUNT(*)
FROM learner_data l
JOIN opportunity_data o
  ON (COALESCE(o."Reward",'') || COALESCE(o."CareerAddOn",'') || COALESCE(o."Cohort",'') ||
      COALESCE(o."Eligibility",'') || COALESCE(o."Testimonial",'') || COALESCE(o."Panellist",'') ||
      COALESCE(o."DropoutTransaction",'') || COALESCE(o."NotStartedTransaction",''))
     LIKE '%' || l.relation_id || '%'
WHERE l.relation_id IS NOT NULL;                                       -- 0

-- work_item_sk against opportunity_data.pk: false positive.
-- pk is not unique, so empty fragments match each other.
SELECT COUNT(*)
FROM learner_data l
JOIN opportunity_data o
  ON split_part(l.work_item_sk, '#', 2) = split_part(o.pk, '#', 2)
WHERE l.work_item_sk IS NOT NULL;                                      -- 28660 (false positive)

-- work_item_sk against opportunity_id: the 15 matches are corrupted rows
SELECT COUNT(*)
FROM learner_data l
JOIN opportunity_data o
  ON split_part(l.work_item_sk, '#', 2) = split_part(o.opportunity_id, '#', 2)
WHERE l.work_item_sk IS NOT NULL;                                      -- 15 (false positive)

-- Cohort codes against the Cohort and Badge JSON columns
SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o."Cohort" LIKE '%' || l.cohort_p1 || '%'
WHERE l.cohort_p1 IS NOT NULL;                                         -- 0

SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o."Badge" LIKE '%' || l.cohort_p1 || '%'
WHERE l.cohort_p1 IS NOT NULL;                                         -- 0

-- external_reference_url holds page-navigation URLs, not opportunity references
SELECT external_reference_url FROM learner_data WHERE external_reference_url IS NOT NULL LIMIT 10;

-- Opportunity "code" against learner identifiers
SELECT code FROM opportunity_data WHERE code IS NOT NULL LIMIT 10;

SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o.code = l.application_id
WHERE l.application_id IS NOT NULL;                                    -- 0

SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o.code = l.transaction_id
WHERE l.transaction_id IS NOT NULL;                                    -- 0

-- Category is the one shared field. Run these after 05 and 06 have created the clean tables.
-- A plain equality join returned 0 rows because of hidden whitespace.
SELECT COUNT(*) FROM opportunity_data_clean o
JOIN learner_data_clean l ON TRIM(o.category) = TRIM(l.category);      -- large, because category is not unique

SELECT DISTINCT category FROM opportunity_data_clean ORDER BY category;
SELECT DISTINCT category FROM learner_data_clean ORDER BY category;
