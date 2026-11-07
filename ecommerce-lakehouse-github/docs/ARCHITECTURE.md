# Architecture

## Medallion layers

### Bronze
Stores source-shaped data ingested from the Olist CSV files as Delta tables. Preserve source lineage and ingestion metadata where implemented.

### Silver
Applies type casting, standardization, deduplication, null handling, and business-rule validation. Keep rejected or incomplete records observable rather than silently discarding them.

### Gold
Provides analytics-ready facts, dimensions, and aggregates for dashboard queries.

## SCD Type 2

The customer dimension should preserve prior versions when tracked attributes change. A typical design includes a business key, surrogate key, effective start/end timestamps, and a current-row flag. Enforce at most one current row per business key and valid effective date ranges.

## Orchestration

A Databricks Job runs notebook tasks in dependency order. The dashboard is a consumer of Gold data and should be refreshed independently after successful data processing.
