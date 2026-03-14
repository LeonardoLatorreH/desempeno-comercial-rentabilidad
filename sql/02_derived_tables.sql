-- Tablas derivadas para el análisis en Power BI.
-- Se generan a partir de las tablas base ya cargadas.


-- Resumen mensual de ventas: base para el análisis de tendencia temporal
SELECT
    d.year,
    d.month,
    d.month_name,
    d.quarter,
    COUNT(DISTINCT f.order_id)             AS total_orders,
    SUM(f.quantity)                        AS units_sold,
    ROUND(SUM(f.sales), 2)                 AS total_sales,
    ROUND(SUM(f.profit), 2)                AS total_profit,
    ROUND(AVG(f.discount) * 100, 2)        AS avg_discount_pct,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2) AS profit_margin_pct
INTO dbo.derived_monthly_summary
FROM dbo.fact_sales f
JOIN dbo.dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name, d.quarter
ORDER BY d.year, d.month;


-- Rentabilidad por producto: detecta productos con alto volumen pero bajo margen
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.sub_category,
    COUNT(DISTINCT f.order_id)             AS total_orders,
    SUM(f.quantity)                        AS units_sold,
    ROUND(SUM(f.sales), 2)                 AS total_sales,
    ROUND(SUM(f.profit), 2)                AS total_profit,
    ROUND(AVG(f.discount) * 100, 2)        AS avg_discount_pct,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2) AS profit_margin_pct
INTO dbo.derived_product_profitability
FROM dbo.fact_sales f
JOIN dbo.dim_products p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category;


-- Desempeño por segmento y región
SELECT
    c.segment,
    c.region,
    c.state,
    COUNT(DISTINCT f.order_id)             AS total_orders,
    COUNT(DISTINCT f.customer_id)          AS unique_customers,
    ROUND(SUM(f.sales), 2)                 AS total_sales,
    ROUND(SUM(f.profit), 2)                AS total_profit,
    ROUND(SUM(f.sales) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS avg_order_value,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2) AS profit_margin_pct
INTO dbo.derived_segment_region
FROM dbo.fact_sales f
JOIN dbo.dim_customers c ON f.customer_id = c.customer_id
GROUP BY c.segment, c.region, c.state;


-- Variación intermensual de ingresos (MoM)
WITH monthly AS (
    SELECT
        d.year,
        d.month,
        ROUND(SUM(f.sales), 2) AS total_sales
    FROM dbo.fact_sales f
    JOIN dbo.dim_date d ON f.date_id = d.date_id
    GROUP BY d.year, d.month
)
SELECT
    year,
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year, month) AS prev_month_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY year, month))
        / NULLIF(LAG(total_sales) OVER (ORDER BY year, month), 0) * 100
    , 2) AS mom_growth_pct
INTO dbo.derived_mom_variation
FROM monthly;
