-- looking for a key between the two tables. nothing held up.

SELECT COUNT(*) FROM learner_data WHERE relation_id IS NOT NULL;

SELECT COUNT(*) FROM learner_data l
WHERE EXISTS (SELECT 1 FROM opportunity_data o WHERE o.opportunity_id = l.relation_id);

SELECT COUNT(*)
FROM learner_data l
JOIN opportunity_data o
  ON (COALESCE(o."Reward",'') || COALESCE(o."CareerAddOn",'') || COALESCE(o."Cohort",'') ||
      COALESCE(o."Eligibility",'') || COALESCE(o."Testimonial",'') || COALESCE(o."Panellist",'') ||
      COALESCE(o."DropoutTransaction",'') || COALESCE(o."NotStartedTransaction",''))
     LIKE '%' || l.relation_id || '%'
WHERE l.relation_id IS NOT NULL;

-- false positive: pk isn't unique
SELECT COUNT(*)
FROM learner_data l
JOIN opportunity_data o
  ON split_part(l.work_item_sk, '#', 2) = split_part(o.pk, '#', 2)
WHERE l.work_item_sk IS NOT NULL;

-- false positive: the 15 matches are corrupted rows
SELECT COUNT(*)
FROM learner_data l
JOIN opportunity_data o
  ON split_part(l.work_item_sk, '#', 2) = split_part(o.opportunity_id, '#', 2)
WHERE l.work_item_sk IS NOT NULL;

SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o."Cohort" LIKE '%' || l.cohort_p1 || '%'
WHERE l.cohort_p1 IS NOT NULL;

SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o."Badge" LIKE '%' || l.cohort_p1 || '%'
WHERE l.cohort_p1 IS NOT NULL;

SELECT external_reference_url FROM learner_data WHERE external_reference_url IS NOT NULL LIMIT 10;

SELECT code FROM opportunity_data WHERE code IS NOT NULL LIMIT 10;

SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o.code = l.application_id
WHERE l.application_id IS NOT NULL;

SELECT COUNT(*) FROM learner_data l
JOIN opportunity_data o ON o.code = l.transaction_id
WHERE l.transaction_id IS NOT NULL;

-- needs the clean tables from 05 and 06
SELECT COUNT(*) FROM opportunity_data_clean o
JOIN learner_data_clean l ON TRIM(o.category) = TRIM(l.category);

SELECT DISTINCT category FROM opportunity_data_clean ORDER BY category;
SELECT DISTINCT category FROM learner_data_clean ORDER BY category;
