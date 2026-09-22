# Telco Customer Churn: Where and Why

An end-to-end analysis of a 7,043-customer telecom dataset, answering two questions: **where** is the company losing customers, and **why**. Built with PostgreSQL for data cleaning and querying, and Power BI for the dashboard.

## Tools

* **PostgreSQL** (pgAdmin) - table setup, type casting, data profiling, and a reporting `VIEW`
* **Power BI Desktop** - two-page interactive dashboard with DAX measures and synced slicers

## Process

1. **Profiled the raw data** and found three columns with heavy nulls (`Churn Reason`, `Churn Category`, `Customer Satisfaction`). Investigation showed the first two are *structurally* null - only populated for customers who actually churned — while satisfaction reflects a genuine \~26% survey response rate.
2. **Built a clean reporting VIEW** (`customers\_clean`) using `COALESCE` and `CASE WHEN` so blanks are labeled explicitly, without touching the raw table.
3. **Queried churn rate by segment** (contract type, internet type) and churn reasons (filtered to actual churners) - see [`telco\_churn\_queries.sql`](./telco_churn_queries.sql) for the full query set.
4. **Built a two-page Power BI dashboard**: a "Where" page (KPI cards, churn rate by contract/internet type) and a "Why" page (churn category/reason breakdown, satisfaction distribution), with three synced slicers (Contract, Tenure, City) and three reusable DAX measures (`Churn Rate`, `Churned Customers`, `Total Customers`).

## Key findings

* **Overall churn rate: 26.5%.**
* **Contract type is the strongest predictor of churn** - Month-to-month customers churn at 45.8%, vs. 10.7% for one-year and just 2.5% for two-year contracts.
* **Cable has the highest churn rate by internet type (51.6%)**, ahead of DSL (31.3%) and Fiber Optic (18.9%) - notable since Fiber is typically the premium tier.
* **Competitor offers are the leading churn category** (841 of 1,869 churned customers, 45%) - customers are mostly leaving for a better deal elsewhere, not primarily due to service failures.
* **Satisfaction scores are structurally split by churn status**: scores of 1–2 were given exclusively by customers who churned; scores of 4–5 exclusively by customers who stayed. This suggests the field functions more like two separate instruments (an exit-dissatisfaction score vs. an ongoing relationship score) than one continuous satisfaction metric.

## Files

* `telco\_churn\_queries.sql` - every SQL query used in the analysis, in order
* `dashboard/dashboard\_where.png`, `dashboard/dashboard\_why.png` - screenshots of the final Power BI dashboard, shown below
* `data/raw/telco\_churn\_data.csv` - the original, unmodified source dataset
* `data/cleaned/customers\_clean.csv` - output of the `customers\_clean` SQL view (see the `CREATE VIEW` statement in `telco\_churn\_queries.sql`), with structural nulls labeled and derived columns (`tenure\_bucket`, etc.) added

## Dashboard

### Where customers are churning

!\[Where dashboard](./dashboard/dashboard\_where.png)

### Why customers are churning

!\[Why dashboard](./dashboard/dashboard\_why.png)

