-- =============================================================
-- Switch to the appropriate staging database
-- =============================================================
USE adashi_staging;

-- =============================================================
-- GOAL:
-- Identify all active savings or investment plans that have had 
-- no transactions in the last 365 days.
-- Useful for triggering inactivity reminders.
-- =============================================================

-- =============================================================
-- STEP 1: Identify the most recent transaction for each plan
-- =============================================================
WITH latest_transactions AS (
    SELECT 
        p.id AS plan_id,         -- Unique plan identifier
        p.owner_id,              -- ID of the user who owns the plan

        -- Determine plan type based on boolean flags
        -- • is_regular_savings = 1 → Savings plan
        -- • is_a_fund = 1         → Investment plan
        -- Any plan that doesn't meet these is ignored in later filtering
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
        END AS type,

        -- Retrieve the most recent transaction date (latest deposit)
        MAX(sa.transaction_date) AS last_transaction_date

    FROM plans_plan p

    -- Inner join ensures only plans with at least one transaction are included here
    JOIN savings_savingsaccount sa 
        ON sa.plan_id = p.id

    -- Group results by plan so we can use MAX() for each
    GROUP BY p.id, p.owner_id, type
)

-- =============================================================
-- STEP 2: Filter to get only plans that have been inactive 
-- (i.e., no deposits) for more than 365 days
-- =============================================================
SELECT 
    plan_id,                       -- The plan ID
    owner_id,                      -- The user who owns the plan
    type,                          -- "Savings" or "Investment"
    last_transaction_date,        -- Date of the last transaction
    DATEDIFF(CURDATE(), last_transaction_date) AS inactivity_days  -- Days since the last deposit
FROM latest_transactions

-- Filter conditions:
-- • Must be inactive for more than 365 days
-- • Must be explicitly either a Savings or Investment plan
WHERE 
    DATEDIFF(CURDATE(), last_transaction_date) > 365
    AND type IN ('Savings', 'Investment')

-- Optional: Sort by how long the plan has been inactive
-- (most inactive plans appear first)
ORDER BY inactivity_days DESC;
