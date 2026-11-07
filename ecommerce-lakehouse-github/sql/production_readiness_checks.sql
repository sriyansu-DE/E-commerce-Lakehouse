-- Production-readiness SQL templates for Databricks SQL.
-- Confirm actual table and column names with DESCRIBE TABLE before running.
-- Run statements individually. Do not update/delete production data as part of validation.

-- 1. Inspect available audit tables
SHOW TABLES IN ecommerce_lakehouse.audit;

DESCRIBE TABLE ecommerce_lakehouse.audit.pipeline_runs;
DESCRIBE TABLE ecommerce_lakehouse.audit.data_quality_results;

-- 2. Inspect Delta transaction history
DESCRIBE HISTORY ecommerce_lakehouse.bronze.orders;
DESCRIBE HISTORY ecommerce_lakehouse.silver.orders;
DESCRIBE HISTORY ecommerce_lakehouse.gold.fact_order_items;

-- 3. Null business keys
SELECT COUNT(*) AS null_order_ids
FROM ecommerce_lakehouse.silver.orders
WHERE order_id IS NULL;

SELECT COUNT(*) AS null_customer_ids
FROM ecommerce_lakehouse.silver.customers
WHERE customer_id IS NULL;

SELECT COUNT(*) AS null_product_ids
FROM ecommerce_lakehouse.silver.products
WHERE product_id IS NULL;

-- 4. Duplicate order keys
SELECT order_id, COUNT(*) AS row_count
FROM ecommerce_lakehouse.silver.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 5. Duplicate order-item composite keys
SELECT order_id, order_item_id, COUNT(*) AS row_count
FROM ecommerce_lakehouse.silver.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- 6. Referential integrity
SELECT COUNT(*) AS orphan_order_items
FROM ecommerce_lakehouse.silver.order_items oi
LEFT JOIN ecommerce_lakehouse.silver.orders o
  ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS orphan_orders
FROM ecommerce_lakehouse.silver.orders o
LEFT JOIN ecommerce_lakehouse.silver.customers c
  ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 7. Domain checks
SELECT COUNT(*) AS negative_prices
FROM ecommerce_lakehouse.silver.order_items
WHERE price < 0;

SELECT COUNT(*) AS negative_freight
FROM ecommerce_lakehouse.silver.order_items
WHERE freight_value < 0;

SELECT COUNT(*) AS negative_payments
FROM ecommerce_lakehouse.silver.payments
WHERE payment_value < 0;

-- 8. Delivered orders with missing customer delivery timestamp.
-- Investigate Bronze vs Silver before deciding whether this is a source exception
-- or a transformation defect. Never fabricate a delivery timestamp.
SELECT COUNT(*) AS delivered_orders_missing_customer_delivery_date
FROM ecommerce_lakehouse.silver.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

-- 9. Invalid delivery date ordering
SELECT COUNT(*) AS delivery_before_purchase
FROM ecommerce_lakehouse.silver.orders
WHERE order_delivered_customer_date < order_purchase_timestamp;

-- 10. SCD Type 2: at most one current version per customer
SELECT customer_id, COUNT(*) AS current_versions
FROM ecommerce_lakehouse.gold.dim_customer
WHERE is_current = true
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 11. SCD Type 2: invalid date ranges
SELECT COUNT(*) AS invalid_scd_date_ranges
FROM ecommerce_lakehouse.gold.dim_customer
WHERE effective_end_date < effective_start_date;

-- 12. Gold revenue reconciliation.
-- These totals should only be compared if both tables use the same revenue
-- definition and include the same population of orders.
SELECT ROUND(SUM(price + freight_value), 2) AS fact_item_revenue
FROM ecommerce_lakehouse.gold.fact_order_items;

SELECT ROUND(SUM(total_revenue), 2) AS daily_sales_revenue
FROM ecommerce_lakehouse.gold.daily_sales;

-- 13. Dashboard source metric examples
SELECT
  COUNT(DISTINCT order_id) AS total_orders
FROM ecommerce_lakehouse.gold.fact_order_items;

SELECT
  ROUND(SUM(total_revenue), 2) AS total_revenue
FROM ecommerce_lakehouse.gold.daily_sales;

-- Average order value: confirm daily_sales contains total_orders and that
-- the business definition matches the dashboard before using this expression.
SELECT
  ROUND(SUM(total_revenue) / NULLIF(SUM(total_orders), 0), 2)
    AS average_order_value
FROM ecommerce_lakehouse.gold.daily_sales;
