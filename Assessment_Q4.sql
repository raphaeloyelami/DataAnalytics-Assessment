-- Switch to the staging database
USE adashi_staging;

-- ==============================================================
-- Goal: Estimate Customer Lifetime Value (CLV) based on account 
-- tenure and transaction volume. CLV is calculated as:
--   CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
-- Assumptions:
--   • Profit per transaction = 0.1% of the transaction value
-- ==============================================================

-- Step 1: Aggregate user data (account tenure, total transactions)
WITH user_data AS (
    SELECT 
        u.id AS customer_id,                     -- User ID
        CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,  -- Account tenure in months
        COUNT(s.id) AS total_transactions,       -- Total number of transactions for the user
        SUM(s.confirmed_amount) AS total_value_kobo  -- Total deposit amount in kobo
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON s.owner_id = u.id  -- Join with savings account table
    GROUP BY u.id, name, tenure_months  -- Group by user ID, name, and tenure
),

-- Step 2: Calculate Estimated Customer Lifetime Value (CLV)
clv_calc AS (
    SELECT 
        customer_id,
        name,
        tenure_months,
        total_transactions,

        -- Calculate estimated CLV: (total_transactions / tenure_months) * 12 * 0.1% of total value
        -- CLV Formula: ((total_transactions / tenure_months) * 12 * (total_value_kobo * 0.001)) / 100
        ROUND(
            ((total_transactions / tenure_months) * 12 * (total_value_kobo * 0.001)) / 100,
            2
        ) AS estimated_clv  -- Round to 2 decimal places for CLV
    FROM user_data
    WHERE tenure_months > 0  -- Exclude users with 0 tenure (prevent division by zero)
)

-- Step 3: Select results and order by estimated CLV from highest to lowest
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    estimated_clv
FROM clv_calc
ORDER BY estimated_clv DESC;  -- Order by CLV in descending order