-- =====================================================
-- Telco Churn Project: Where is the company losing
-- customers, and why?
-- Built in PostgreSQL (pgAdmin)
-- =====================================================

-- 1. TABLE SETUP
CREATE TABLE customers (
  "Customer ID" TEXT, "Referred a Friend" TEXT, "Number of Referrals" TEXT,
  "Tenure in Months" TEXT, "Offer" TEXT, "Phone Service" TEXT,
  "Avg Monthly Long Distance Charges" TEXT, "Multiple Lines" TEXT, "Internet Service" TEXT,
  "Internet Type" TEXT, "Avg Monthly GB Download" TEXT, "Online Security" TEXT,
  "Online Backup" TEXT, "Device Protection Plan" TEXT, "Premium Tech Support" TEXT,
  "Streaming TV" TEXT, "Streaming Movies" TEXT, "Streaming Music" TEXT, "Unlimited Data" TEXT,
  "Contract" TEXT, "Paperless Billing" TEXT, "Payment Method" TEXT, "Monthly Charge" TEXT,
  "Total Regular Charges" TEXT, "Total Refunds" TEXT, "Total Extra Data Charges" TEXT,
  "Total Long Distance Charges" TEXT, "Gender" TEXT, "Age" TEXT, "Under 30" TEXT,
  "Senior Citizen" TEXT, "Married" TEXT, "Dependents" TEXT, "Number of Dependents" TEXT,
  "City" TEXT, "Zip Code" TEXT, "Latitude" TEXT, "Longitude" TEXT, "Population" TEXT,
  "Churn Value" TEXT, "CLTV" TEXT, "Churn Category" TEXT, "Churn Reason" TEXT,
  "Total Customer Svc Requests" TEXT, "Product/Service Issues Reported" TEXT,
  "Customer Satisfaction" TEXT
);
-- Data imported via pgAdmin's Import/Export Data tool from telco_churn_data.csv

-- Convert key columns from text to real numeric types after import
ALTER TABLE customers
  ALTER COLUMN "Churn Value" TYPE INTEGER USING "Churn Value"::INTEGER,
  ALTER COLUMN "Tenure in Months" TYPE INTEGER USING "Tenure in Months"::INTEGER,
  ALTER COLUMN "Monthly Charge" TYPE NUMERIC USING "Monthly Charge"::NUMERIC,
  ALTER COLUMN "Customer Satisfaction" TYPE NUMERIC USING NULLIF("Customer Satisfaction", '')::NUMERIC,
  ALTER COLUMN "CLTV" TYPE NUMERIC USING "CLTV"::NUMERIC;


-- 2. DATA PROFILING

-- Row count / duplicate check
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT "Customer ID") AS unique_customers
FROM customers;

-- Null counts in the three flagged columns
SELECT
  SUM(CASE WHEN "Churn Reason" IS NULL THEN 1 ELSE 0 END) AS null_churn_reason,
  SUM(CASE WHEN "Churn Category" IS NULL THEN 1 ELSE 0 END) AS null_churn_category,
  SUM(CASE WHEN "Customer Satisfaction" IS NULL THEN 1 ELSE 0 END) AS null_satisfaction
FROM customers;

-- Confirm Churn Value is clean binary
SELECT "Churn Value", COUNT(*) FROM customers GROUP BY "Churn Value";


-- 3. WHERE: CHURN RATE BY SEGMENT

-- Overall churn rate
SELECT ROUND(AVG("Churn Value") * 100, 1) AS churn_rate_pct
FROM customers;

-- By contract type
SELECT "Contract",
       COUNT(*) AS customers,
       SUM("Churn Value") AS churned,
       ROUND(AVG("Churn Value") * 100, 1) AS churn_rate_pct
FROM customers
GROUP BY "Contract"
ORDER BY churn_rate_pct DESC;

-- By internet type
SELECT "Internet Type",
       COUNT(*) AS customers,
       SUM("Churn Value") AS churned,
       ROUND(AVG("Churn Value") * 100, 1) AS churn_rate_pct
FROM customers
GROUP BY "Internet Type"
ORDER BY churn_rate_pct DESC;


-- 4. WHY: CHURN REASONS (churners only)

-- Top-level churn categories
SELECT "Churn Category", COUNT(*) AS churned_customers
FROM customers
WHERE "Churn Value" = 1
GROUP BY "Churn Category"
ORDER BY churned_customers DESC;

-- Category + specific reason
SELECT "Churn Category", "Churn Reason", COUNT(*) AS churned_customers
FROM customers
WHERE "Churn Value" = 1
GROUP BY "Churn Category", "Churn Reason"
ORDER BY "Churn Category", churned_customers DESC;

-- Top 10 specific reasons overall
SELECT "Churn Reason", COUNT(*) AS churned_customers
FROM customers
WHERE "Churn Value" = 1
GROUP BY "Churn Reason"
ORDER BY churned_customers DESC
LIMIT 10;


-- 5. CLEAN REPORTING VIEW
-- Wraps the raw table without altering it. Power BI connects to this view.
CREATE VIEW customers_clean AS
SELECT *,
  COALESCE("Churn Category", 'Not Churned') AS churn_category_clean,
  COALESCE("Churn Reason", 'Not Churned') AS churn_reason_clean,
  CASE WHEN "Customer Satisfaction" IS NULL THEN 'No Response'
       ELSE CAST("Customer Satisfaction" AS TEXT)
  END AS satisfaction_clean,
  CASE
    WHEN "Tenure in Months" < 12 THEN '0-1 yr'
    WHEN "Tenure in Months" < 24 THEN '1-2 yr'
    WHEN "Tenure in Months" < 48 THEN '2-4 yr'
    ELSE '4+ yr'
  END AS tenure_bucket,
  CASE WHEN "Customer Satisfaction" IS NULL THEN 'No Response' ELSE 'Responded' END AS satisfaction_response_flag
FROM customers;


-- 6. FINDING: SATISFACTION SCORE IS STRUCTURALLY SPLIT BY CHURN
-- Scores 1-2 are given exclusively by churned customers;
-- scores 4-5 exclusively by retained customers; only 3 overlaps.
SELECT "Customer Satisfaction", "Churn Value", COUNT(*) AS customers
FROM customers
WHERE "Customer Satisfaction" IS NOT NULL
GROUP BY "Customer Satisfaction", "Churn Value"
ORDER BY "Customer Satisfaction", "Churn Value";
