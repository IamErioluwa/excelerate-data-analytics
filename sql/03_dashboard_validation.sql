-- Validate Chart 1: Opportunities by category
SELECT TRIM(category) AS category, COUNT(*) 
FROM opportunity_data_clean 
GROUP BY TRIM(category) ORDER BY COUNT(*) DESC;

-- Validate Chart 6: Applications per month
SELECT DATE_TRUNC('month', apply_date) AS month, COUNT(*) 
FROM learner_data_clean 
WHERE apply_date IS NOT NULL 
GROUP BY month ORDER BY month;

-- Validate Chart 7: Records by payment status
SELECT payment_status, COUNT(*) 
FROM learner_data_clean 
GROUP BY payment_status ORDER BY COUNT(*) DESC;

-- Validate Chart 8: Lead source
SELECT from_where_did_you_hear_about_us, COUNT(*) 
FROM learner_data_clean 
GROUP BY from_where_did_you_hear_about_us ORDER BY COUNT(*) DESC;