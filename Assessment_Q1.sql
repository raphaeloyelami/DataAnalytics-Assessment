-- Switch to the adashi_staging database
USE adashi_staging;

-- ========================================
-- Goal: Identify users who have both:
--   • At least one funded savings plan
--   • At least one funded investment plan
-- Then sort these users by the total amount deposited
-- ========================================

SELECT 
    u.id AS owner_id,  -- ID of the user (owner of the plan)
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- User's full name

    -- Count of distinct savings plans owned by the user
    -- A plan is considered a savings plan if is_regular_savings = 1
    COUNT(DISTINCT CASE
            WHEN p.is_regular_savings = 1 THEN p.id
        END) AS savings_count,

    -- Count of distinct investment plans owned by the user
    -- A plan is considered an investment plan if is_a_fund = 1
    COUNT(DISTINCT CASE
            WHEN p.is_a_fund = 1 THEN p.id
        END) AS investment_count,

    -- Total sum of confirmed deposits for all plans, converted from kobo to naira
    ROUND(SUM(s.confirmed_amount) / 100, 2) AS total_deposits

FROM
    users_customuser u  -- Table containing user data

    -- Join with the plans_plan table to get all plans owned by each user
    JOIN plans_plan p ON p.owner_id = u.id

    -- Join with savings_savingsaccount to get deposit information
    -- Only include savings accounts with confirmed_amount > 0 (i.e., funded)
    JOIN savings_savingsaccount s 
        ON s.plan_id = p.id
        AND s.confirmed_amount > 0

-- Group the results by user ID and full name to aggregate plan counts and deposits per user
GROUP BY 
    u.id, 
    name

-- Only include users who have:
--  • At least one funded savings plan
--  • At least one funded investment plan
HAVING 
    savings_count > 0
    AND investment_count > 0

-- Sort the results in descending order of total deposit value
ORDER BY 
    total_deposits DESC;