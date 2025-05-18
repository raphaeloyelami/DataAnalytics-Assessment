-- Switch to the adashi_staging database
USE adashi_staging;

-- ============================================================
-- Goal: Segment users based on how frequently they make transactions
-- Segmentation Criteria:
--   • High Frequency    => 10 or more transactions per month
--   • Medium Frequency  => Between 3 and 9 transactions per month
--   • Low Frequency     => 0 to 2 transactions per month
-- The logic uses the number of deposit transactions per month
-- ============================================================

-- ============================================
-- Step 1: Calculate number of transactions and
-- the number of active months for each user
-- ============================================
WITH user_transactions AS (
    SELECT 
        sa.owner_id,  -- ID of the user who made the transaction

        -- Count the total number of transactions made by the user
        COUNT(sa.id) AS total_transactions,

        -- Calculate number of months between the user's first and last transaction
        -- Add 1 to ensure at least one active month is counted (e.g. if min=max)
        TIMESTAMPDIFF(MONTH, MIN(sa.transaction_date), MAX(sa.transaction_date)) + 1 AS active_months
    FROM savings_savingsaccount sa
    GROUP BY sa.owner_id  -- Aggregate per user
),

-- ====================================================
-- Step 2: Categorize users into frequency segments
-- based on average number of transactions per month
-- ====================================================
segment_categorized AS (
    SELECT 
        owner_id,
        total_transactions,
        active_months,

        -- Compute average number of transactions per month
        total_transactions / active_months AS transactions_per_month,

        -- Apply segmentation logic:
        -- ≥ 10/month = High Frequency
        -- 3 to 9/month = Medium Frequency
        -- < 3/month = Low Frequency
        CASE
            WHEN total_transactions / active_months >= 10 THEN 'High Frequency'
            WHEN total_transactions / active_months BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS segment_category
    FROM user_transactions
)

-- ====================================================
-- Step 3: Aggregate and report on each frequency group
-- Provides: count of users and average activity level
-- ====================================================
SELECT 
    segment_category,  -- Frequency segment: High, Medium, or Low
    COUNT(*) AS customer_count,  -- Number of users in each segment

    -- Average number of transactions per month, rounded to 1 decimal
    ROUND(AVG(transactions_per_month), 1) AS avg_transactions_per_month
FROM segment_categorized
GROUP BY segment_category
ORDER BY avg_transactions_per_month DESC;  -- Show most active segments first