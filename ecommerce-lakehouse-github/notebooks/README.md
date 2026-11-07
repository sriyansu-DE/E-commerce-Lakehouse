# Databricks notebooks

Export the actual, tested notebooks from your Databricks workspace into this directory.

Recommended names (adapt to the notebooks that really exist):

1. `01_setup.py`
2. `02_bronze_ingestion.py`
3. `03_silver_transformation.py`
4. `04_data_quality.py`
5. `05_scd_type2.py`
6. `06_gold_layer.py`
7. `07_incremental_processing.py`
8. `08_optimization.py`
9. `09_dashboard_queries.sql`
10. `10_monitoring.py`

## Export from Databricks

In the workspace browser, open the notebook's context menu and use **Export** / **Download** / **Export as source** (the exact label varies). Prefer source format (`.py` or `.sql`) for Git version control. Add the exported file here, review it for secrets and workspace-specific paths, then commit it.

Do not create empty placeholder notebooks and describe them as implemented. This folder intentionally starts as documentation until your actual notebook source is exported.
