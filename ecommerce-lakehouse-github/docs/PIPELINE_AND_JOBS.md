# Pipeline and Jobs

Document the actual job configured in your Databricks workspace.

## Job details

- Job name: `E-Commerce Lakehouse ETL Pipeline`
- Schedule: record the actual schedule (manual during initial testing is recommended)
- Compute: record the selected Databricks compute type
- Catalog/schema: `ecommerce_lakehouse` / `bronze`, `silver`, `gold`, `audit`

## Task dependency template

| Order | Task | Depends on |
|---:|---|---|
| 1 | Bronze ingestion | None |
| 2 | Silver transformation | Bronze ingestion |
| 3 | Data quality | Silver transformation |
| 4 | SCD Type 2 | Data quality |
| 5 | Gold layer | SCD Type 2 |
| 6 | Monitoring | Gold layer |

Adjust this table to match the real task graph. If data quality is configured to warn rather than fail, document that policy.

## Recovery procedure

1. Open the failed job run and inspect the failed task output.
2. Identify and fix the root cause.
3. Use Repair run when appropriate and supported, or start a new run.
4. Verify downstream task status.
5. Re-run relevant duplicate, reconciliation, and data quality checks.
6. Record the incident and resolution in the validation report.
