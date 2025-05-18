# DataAnalytics-Assessment

![image](https://static-00.iconduck.com/assets.00/cowrywise-icon-2048x378-o34mit38.png)

A MySQL-based analytics assessment to evaluate customer behavior, transaction patterns, and engagement levels across savings and investment products. Includes SQL queries, data model analysis, ERD, and business-driven insights for segmentation, inactivity detection, and lifetime value estimation.

## 📌 Project Overview

This project focuses on building robust SQL queries to extract key business insights from Cowrywise's relational database. The data revolves around customer profiles, savings and investment behavior, and transactional activity. These insights are intended for use by teams in **marketing**, **operations**, **finance**, and **product strategy** to drive better decision-making and customer engagement.

---

## 🛠️ Important Links & Tools:

- **[Datasets](https://drive.google.com/file/d/1hK2Ht5zw7m22sskJR2KCYiC1Kl6iZ48n/view?usp=sharing):** Access to the project dataset (sql file).
- **[MySQL Workbench](https://dev.mysql.com/downloads/workbench/):** GUI for managing and interacting with databases.
- **[Git Repository](https://github.com/):** Set up a GitHub account and repository to manage, version, and collaborate on your code efficiently.
- **[Assessment](https://docs.google.com/document/d/1qGaMGhLRYG3IsBfSHNrj8D5VlmxtjZxns17zC76T_5g/edit?usp=sharing):** Instruction for the assessment
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.

---

## 🎯 Objectives

The primary goals of this assessment are:

1. **Customer Segmentation** – Identify high-value users who use multiple financial products.
2. **Behavioral Analytics** – Track how often customers transact to better target service offerings.
3. **Risk & Ops Monitoring** – Detect inactive accounts for follow-up or dormancy management.
4. **Customer Lifetime Value (CLV)** – Estimate user profitability over time based on transaction activity and tenure.

---

## 🗃️ Database Schema & Tables

The analysis is built on four main tables:

| Table Name              | Description                                                                 |
|-------------------------|-----------------------------------------------------------------------------|
| `users_customuser`      | Stores customer demographic, contact, and account metadata                  |
| `savings_savingsaccount`| Logs confirmed savings deposits and associated plan data                    |
| `plans_plan`            | Contains metadata for customer-created savings or investment plans          |
| `withdrawals_withdrawal`| Tracks all customer withdrawal activities, including channel and status     |

> **Note**: Monetary values are stored in **kobo** (₦1 = 100 kobo) and must be converted to naira for reporting.

---

### ⚙️ Relationships:
- `plans_plan.owner_id` → `users_customuser.id`
- `savings_savingsaccount.owner_id` → `users_customuser.id`
- `savings_savingsaccount.plan_id` → `plans_plan.id`
- `withdrawals_withdrawal.owner_id` → `users_customuser.id`
- `withdrawals_withdrawal.plan_id` → `plans_plan.id`

### For this assessement, the withdrawals_withdrawal table was not used.

![Image](https://github.com/user-attachments/assets/eedd32ea-b549-4c7a-a78f-683668f1833f)

### The ERD includes only the columns relevant to the queries because its purpose is to highlight the data elements directly involved in solving the business problem. Including all columns would add unnecessary complexity and reduce clarity, so I focused solely on those essential columns for the analysis.

---

## 🔍 Per-Question Explanations

### 1. High-Value Customers with Multiple Products

**Purpose:** Find users who have both a funded savings plan and at least one funded investment plan.

**Logic:**
- Group savings and investments by owner
- Use conditional aggregation to separate savings and investments
- Sum all confirmed amounts to measure total value
- Filter only users with ≥1 in both product types

**Insight:** Helps the business identify users suitable for upselling, loyalty rewards, or cross-sell marketing.

---

### 2. Transaction Frequency Analysis

**Purpose:** Segment users into activity bands for marketing and retention strategy.

**Logic:**
- Count number of transactions per user
- Divide by number of months active to get monthly rate
- Use `CASE` statement to classify into frequency categories
- Group by category for summary metrics

**Insight:** Enables personalized user journeys: high-frequency users may get VIP perks, while low-frequency users can be re-engaged.

---

### 3. Account Inactivity Alert

**Purpose:** Identify dormant accounts that haven't made a transaction in over 1 year.

**Logic:**
- Get the latest transaction per plan
- Compare to `CURRENT_DATE` using `DATEDIFF()`
- Only include savings or investment plans with no recent inflows

**Insight:** Triggers operational alerts for account cleanup, reactivation, or regulatory handling (e.g. dormancy notifications).

---

### 4. Customer Lifetime Value (CLV) Estimation

**Purpose:** Estimate the monetary value each customer brings based on past behavior.

**Logic:**
- Count total transactions and sum confirmed amounts
- Calculate tenure in months since signup
- Use the formula:
`CLV = (total_value / tenure) * 12 * 0.001`
- Order by descending CLV

**Insight:** Supports marketing spend calibration, retention efforts, and VIP segmentation.

---

## 🧗 Challenges Faced

### 🔄 1. Data Normalization Across Plans
**Issue:** Both savings and investments were stored in `savings_savingsaccount` but differentiated only by flags in `plans_plan`.

**Solution:** Joined with `plans_plan` to extract `is_a_fund` and `is_regular_savings`, then used conditional aggregation.

---

### 🧮 2. Monthly Frequency Normalization
**Issue:** Needed accurate month-based transaction rate per user regardless of when they joined.

**Solution:** Used `TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date)) + 1` to avoid zero-division and account for partial months.

---

### 🕵️ 3. Estimating CLV with Simplified Assumptions
**Issue:** No direct profit or cost data available.

**Solution:** Modeled based on a simplified assumption of 0.1% profit per deposit to allow meaningful comparisons without overfitting.

---

## 📂 Repository Structure
```
DataAnalytics-Assessment/
│
├── Assessment_Q1.sql                  # Query 1
│
├── Assessment_Q2.sql                  # Query 2
│
├── Assessment_Q3.sql                  # Query 3
│
├── Assessment_Q4.sql                  # Query 4
│   
└── README.md                          # Project overview and instructions
```
