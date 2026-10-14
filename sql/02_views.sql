-- Create category summary view to bypass missing record-level keys
CREATE OR REPLACE VIEW integrated_category_summary AS
WITH opp_summary AS (
    SELECT 
        TRIM(category) AS clean_category,
        COUNT(opportunity_id) AS total_opportunities,
        ROUND(AVG(fee::numeric), 2) AS avg_fee
    FROM opportunity_data_clean
    WHERE category IS NOT NULL
    GROUP BY TRIM(category)
),
learner_summary AS (
    SELECT 
        TRIM(category) AS clean_category,
        COUNT(application_id) AS learner_applications,
        COUNT(completion_date) AS learner_completions
    FROM learner_data_clean
    WHERE category IS NOT NULL
    GROUP BY TRIM(category)
)
SELECT 
    o.clean_category AS category,
    o.total_opportunities,
    o.avg_fee,
    COALESCE(l.learner_applications, 0) AS learner_applications,
    COALESCE(l.learner_completions, 0) AS learner_completions
FROM opp_summary o
LEFT JOIN learner_summary l ON o.clean_category = l.clean_category;