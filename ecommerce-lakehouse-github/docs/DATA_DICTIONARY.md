# Data dictionary

Fill this document from the actual schemas in your Databricks catalog.

| Layer | Table | Grain | Primary/business key | Description |
|---|---|---|---|---|
| Bronze | orders | One source order | order_id | Raw order source |
| Silver | orders | One cleaned order | order_id | Standardized order |
| Silver | order_items | One item within an order | order_id + order_item_id | Order line details |
| Gold | dim_customer | One customer version | customer surrogate key | SCD Type 2 customer dimension |
| Gold | fact_order_items | One order item | order_id + order_item_id | Order-item fact |
| Gold | daily_sales | One calendar day | date key | Daily sales aggregate |

Add every implemented table, its actual columns, data types, grain, keys, and business definition. Do not assume that table names or columns in this template exactly match your workspace.
