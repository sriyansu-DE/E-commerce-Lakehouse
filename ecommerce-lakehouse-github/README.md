# Enterprise E-Commerce Lakehouse on Databricks

An end-to-end data engineering project built with **Databricks, Apache Spark / PySpark, Delta Lake, and Databricks SQL** using the Olist Brazilian E-Commerce Public Dataset.

The project demonstrates a medallion lakehouse architecture, data quality checks, SCD Type 2 customer history, Gold-layer analytics, job orchestration, dashboarding, and operational validation.

> **Repository note:** This repository is a GitHub-ready project structure and documentation starter. Export your actual working Databricks notebooks into `notebooks/` before publishing. Replace any example paths, column names, screenshots, and configuration values with those used in your workspace.

## Architecture

```text
Olist CSV files
      |
      v
Bronze (raw Delta tables)
      |
      v
Silver (cleaned and standardized Delta tables)
      |
      +----> Data quality checks
      |
      +----> SCD Type 2 customer dimension
      |
      v
Gold (facts, dimensions, and analytics tables)
      |
      +----> Databricks SQL / AI-BI Dashboard
      |
      +----> Downstream analytics

Databricks Jobs orchestrate notebook tasks.
Audit tables, Delta history, and run monitoring support operations.
```

## Technology stack

- Databricks workspace and Jobs
- Apache Spark / PySpark
- Delta Lake
- Unity Catalog (if enabled in the workspace)
- Databricks SQL and AI/BI Dashboards
- SQL for validation and analytics
- Git and GitHub for version control

## Dataset

**Olist Brazilian E-Commerce Public Dataset**  
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset contains related CSV files for customers, orders, order items, payments, reviews, products, sellers, geolocation, and product-category translation.

Follow Kaggle's terms and dataset license. Do not commit the downloaded raw dataset unless you have checked that redistribution is permitted. Prefer documenting how to download it and keeping raw files outside Git.

## Lakehouse objects

The project has been organized around the following Unity Catalog naming convention:

- Catalog: `ecommerce_lakehouse`
- Schemas: `bronze`, `silver`, `gold`, `audit`

### Bronze
- `bronze.customers`
- `bronze.orders`
- `bronze.order_items`
- `bronze.order_payments` or `bronze.payments` (use the name in your workspace)
- `bronze.order_reviews` or `bronze.reviews` (use the name in your workspace)
- `bronze.products`
- `bronze.sellers`
- `bronze.geolocation`
- `bronze.category_translation`

### Silver
Cleaned and standardized versions of the source entities. Keep the actual table names consistent with the notebooks in this repository.

### Gold
The analytical layer may include:
- `gold.dim_customer` (SCD Type 2)
- `gold.dim_product`
- `gold.dim_seller`
- `gold.fact_order_items`
- `gold.daily_sales`
- `gold.product_performance`
- `gold.payment_analysis` / `gold.payment_summary`
- `gold.review_summary`
- `gold.delivery_performance`
- `gold.customer_360`
- `gold.seller_performance`

### Audit
- `audit.pipeline_runs`
- `audit.data_quality_results`

> Table names and columns can differ across implementations. The SQL in `sql/` is a validation template: adjust names to match the actual tables in your workspace.

## Suggested repository layout

```text
ecommerce-lakehouse/
├── README.md
├── .gitignore
├── LICENSE
├── notebooks/
│   └── README.md
├── sql/
│   └── production_readiness_checks.sql
├── docs/
│   ├── ARCHITECTURE.md
│   ├── PIPELINE_AND_JOBS.md
│   ├── DATA_DICTIONARY.md
│   └── VALIDATION_REPORT_TEMPLATE.md
└── images/
    └── README.md
```

Export your Databricks notebooks as source files (`.py` or `.sql`) and add them under `notebooks/` with clear numbered names, for example:

```text
notebooks/
├── 01_setup.py
├── 02_bronze_ingestion.py
├── 03_silver_transformation.py
├── 04_data_quality.py
├── 05_scd_type2.py
├── 06_gold_layer.py
├── 07_incremental_processing.py
├── 08_optimization.py
├── 09_dashboard_queries.sql
└── 10_monitoring.py
```

Only include files that actually exist and have been tested. If a feature is not implemented, mark it as planned rather than completed.

## Setup and execution

1. Create or open a Databricks workspace with compatible compute.
2. Download the Olist dataset from Kaggle.
3. Upload the CSV files to a Unity Catalog Volume or another storage location accessible to the workspace.
4. Update the input paths and catalog/schema settings in the notebooks.
5. Run notebooks in dependency order:
   1. Setup
   2. Bronze ingestion
   3. Silver transformation
   4. Data quality
   5. SCD Type 2
   6. Gold layer
   7. Incremental processing (if configured)
   8. Optimization
   9. Dashboard queries
   10. Monitoring
6. Configure a Databricks Job with notebook tasks and dependencies matching the actual pipeline.
7. Run the job and inspect task status, logs, and audit records.
8. Open the AI/BI Dashboard and refresh it after Gold tables have been updated.

### Important data behavior

The Olist dataset is a historical snapshot, not a live streaming feed. Auto Loader or incremental processing in this project demonstrates how newly arriving files can be handled; it does not make the original Olist dataset a live source.

SCD Type 2 requires changed source records to create new dimension versions. If the source snapshot does not contain customer changes, use a clearly labelled test fixture or controlled test record to validate the SCD2 process. Do not present simulated changes as real Olist history.

## Production-readiness validation

Use `sql/production_readiness_checks.sql` as a starting point. The validation plan should cover:

- Job task order and failure dependencies
- Idempotent reruns with unchanged inputs
- Duplicate business keys
- SCD Type 2 current-row and date-range rules
- Null and domain checks
- Referential integrity
- Gold metric reconciliation
- Dashboard-to-Gold reconciliation
- Audit logging, failure detection, and recovery

Document actual outcomes in `docs/VALIDATION_REPORT_TEMPLATE.md`. A query running successfully is not by itself proof that the check passed; record the returned values and evidence.

## Dashboard

The AI/BI Dashboard should read from Gold tables and remain separate from the ETL notebook task graph. Configure dashboard/query refresh independently, ideally after the ETL job has completed successfully.

Suggested dashboard metrics:
- Total revenue
- Total orders
- Average order value
- Daily revenue trend
- Top product categories
- Payment method distribution
- Delivery performance
- Top sellers
- Customer segments
- Review distribution

Check each metric's business definition and aggregation. For example, do not sum order-level payment amounts after joining them onto every order-item row; that duplicates order-level values.

## Connect this repository to GitHub

### Option A — Push from your computer (VS Code / Git)

1. Create a **new empty GitHub repository**. Do not initialize it with a README if you plan to push this folder as-is.
2. Download and extract this project ZIP.
3. Open the extracted `ecommerce-lakehouse-github` folder in VS Code.
4. Open **Terminal → New Terminal**.
5. Run the following commands, replacing the URL with your own repository URL:

```bash
git init
git add .
git commit -m "Initial commit: E-Commerce Lakehouse project"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

6. Refresh your GitHub repository page. Your README should appear on the front page.

If Git asks you to authenticate, complete the browser sign-in flow or use GitHub's supported credential manager. Do not put a password or personal access token directly into the command or commit it to a file.

### Option B — Connect Databricks directly to GitHub

1. In Databricks, open **Workspace** and find **Git folders** (the label may vary by workspace version).
2. Choose **Add Git folder** / **Clone repository**.
3. Paste your GitHub repository HTTPS URL.
4. Authenticate with the Git provider when prompted.
5. Choose the branch, normally `main`.
6. Clone the repository into the workspace.
7. Export or copy your tested workspace notebooks into the repository's `notebooks/` directory.
8. Commit and push from the Databricks Git folder using its Git interface.

If your workspace does not expose Git folders or Git integration in the current plan, use Option A from VS Code.

## Before making the repository public

- Remove passwords, tokens, API keys, personal access tokens, and connection strings.
- Do not commit `.env`, local credential files, or private keys.
- Do not commit database exports or raw data unless redistribution is allowed.
- Check notebook outputs for personal information and secrets.
- Confirm all notebook paths and table names are correct.
- Add screenshots only after removing sensitive workspace identifiers.
- Add a license only if you have chosen one and understand its terms.

## Project status

Update this section to reflect the actual implementation and validation evidence.

- [x] Bronze / Silver / Gold architecture (implemented in Databricks workspace; export notebooks before claiming repository completeness)
- [x] Databricks Job orchestration (verify actual task graph)
- [x] SCD Type 2 checks (record evidence in validation report)
- [x] Idempotency checks (record before/after counts)
- [ ] Resolve/document delivered orders with missing delivery timestamps
- [ ] Complete dashboard-to-Gold metric reconciliation
- [ ] Complete failure notification and recovery evidence
- [ ] Export all tested notebooks and add dashboard screenshots

## Author

**Sriyansu Parida**

Add your LinkedIn and portfolio links here if you want them displayed publicly.
