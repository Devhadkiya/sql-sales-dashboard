-- ================================================
-- Retail Sales Dashboard — Analysis Queries
-- Run in MySQL Workbench after loading data
-- ================================================

USE retail_sales;

-- ------------------------------------------------
-- KPI 1: Total Revenue, Orders and Avg Order Value
-- ------------------------------------------------
SELECT
    COUNT(sale_id)            AS total_orders,
    ROUND(SUM(revenue), 2)    AS total_revenue,
    ROUND(AVG(revenue), 2)    AS avg_order_value,
    SUM(quantity)             AS total_units_sold
FROM sales;

-- ------------------------------------------------
-- KPI 2: Monthly Revenue Trend
-- ------------------------------------------------
SELECT
    DATE_FORMAT(sale_date, '%Y-%m')   AS month,
    ROUND(SUM(revenue), 2)            AS monthly_revenue,
    COUNT(sale_id)                    AS total_orders
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
ORDER BY month;

-- ------------------------------------------------
-- KPI 3: Revenue by Region
-- ------------------------------------------------
SELECT
    region,
    ROUND(SUM(revenue), 2)                          AS total_revenue,
    COUNT(sale_id)                                  AS total_orders,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue))
          OVER (), 2)                               AS revenue_pct
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;

-- ------------------------------------------------
-- KPI 4: Revenue by Category
-- ------------------------------------------------
SELECT
    category,
    ROUND(SUM(revenue), 2)    AS total_revenue,
    SUM(quantity)             AS units_sold,
    COUNT(sale_id)            AS total_orders,
    ROUND(AVG(revenue), 2)    AS avg_order_value
FROM sales
GROUP BY category
ORDER BY total_revenue DESC;

-- ------------------------------------------------
-- KPI 5: Top 10 Best Selling Products
-- ------------------------------------------------
SELECT
    product_name,
    category,
    SUM(quantity)             AS units_sold,
    ROUND(SUM(revenue), 2)    AS total_revenue
FROM sales
GROUP BY product_name, category
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------
-- KPI 6: Revenue Growth Rate Month over Month
-- (uses CTE + window function)
-- ------------------------------------------------
WITH monthly AS (
    SELECT
        DATE_FORMAT(sale_date, '%Y-%m')  AS month,
        ROUND(SUM(revenue), 2)           AS monthly_revenue
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
)
SELECT
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY month)   AS prev_month_revenue,
    ROUND(
        (monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month))
        * 100.0
        / LAG(monthly_revenue) OVER (ORDER BY month)
    , 2)                                         AS growth_rate_pct
FROM monthly
ORDER BY month;

-- ------------------------------------------------
-- KPI 7: Top 10 Customers by Revenue
-- (uses JOIN between sales and customers)
-- ------------------------------------------------
SELECT
    c.customer_id,
    c.customer_name,
    c.region,
    COUNT(s.sale_id)           AS total_orders,
    ROUND(SUM(s.revenue), 2)   AS total_revenue
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.region
ORDER BY total_revenue DESC
LIMIT 10;

-- ------------------------------------------------
-- KPI 8: Regional Performance with Ranking
-- (uses window function RANK)
-- ------------------------------------------------
SELECT
    region,
    category,
    ROUND(SUM(revenue), 2)                              AS total_revenue,
    RANK() OVER (PARTITION BY region ORDER BY
                 SUM(revenue) DESC)                     AS category_rank_in_region
FROM sales
GROUP BY region, category
ORDER BY region, category_rank_in_region;