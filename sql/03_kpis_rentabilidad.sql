-- Consultas de rentabilidad y desempeño comercial para validar
-- los resultados antes de conectar Power BI.


-- Ingresos netos, margen bruto y ticket promedio por año
SELECT
    d.year,
    COUNT(DISTINCT f.order_id)             AS pedidos,
    ROUND(SUM(f.sales), 2)                 AS ingresos_netos,
    ROUND(SUM(f.profit), 2)                AS margen_bruto,
    ROUND(SUM(f.sales) / NULLIF(COUNT(DISTINCT f.order_id), 0), 2) AS ticket_promedio,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2) AS margen_pct
FROM dbo.fact_sales f
JOIN dbo.dim_date d ON f.date_id = d.date_id
GROUP BY d.year
ORDER BY d.year;


-- Margen de contribución por subcategoría
-- Margen de contribución = ingresos - descuentos aplicados - costo estimado
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(f.sales), 2)                                    AS ingresos,
    ROUND(SUM(f.sales * f.discount), 2)                       AS descuentos_aplicados,
    ROUND(SUM(f.profit), 2)                                   AS beneficio,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2)  AS margen_contribucion_pct
FROM dbo.fact_sales f
JOIN dbo.dim_products p ON f.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY margen_contribucion_pct DESC;


-- Productos con alto volumen pero baja rentabilidad
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    SUM(f.quantity)                        AS unidades,
    ROUND(SUM(f.sales), 2)                 AS ingresos,
    ROUND(SUM(f.profit), 2)                AS beneficio,
    ROUND(AVG(f.discount) * 100, 2)        AS descuento_promedio_pct,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2) AS margen_pct
FROM dbo.fact_sales f
JOIN dbo.dim_products p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
HAVING SUM(f.quantity) > 50
   AND SUM(f.profit) / NULLIF(SUM(f.sales), 0) < 0.05
ORDER BY ingresos DESC;


-- Impacto del descuento sobre el margen efectivo
SELECT
    CASE
        WHEN f.discount = 0      THEN '0% — sin descuento'
        WHEN f.discount <= 0.20  THEN '1% – 20%'
        WHEN f.discount <= 0.40  THEN '21% – 40%'
        ELSE                          '> 40%'
    END                              AS banda_descuento,
    COUNT(*)                         AS transacciones,
    ROUND(SUM(f.sales), 2)           AS ingresos,
    ROUND(SUM(f.profit), 2)          AS beneficio,
    ROUND(SUM(f.profit) / NULLIF(SUM(f.sales), 0) * 100, 2) AS margen_efectivo_pct
FROM dbo.fact_sales f
GROUP BY
    CASE
        WHEN f.discount = 0      THEN '0% — sin descuento'
        WHEN f.discount <= 0.20  THEN '1% – 20%'
        WHEN f.discount <= 0.40  THEN '21% – 40%'
        ELSE                          '> 40%'
    END
ORDER BY margen_efectivo_pct DESC;


-- Comparativo de ingresos año sobre año por categoría
SELECT
    p.category,
    d.year,
    ROUND(SUM(f.sales), 2) AS ingresos,
    ROUND(
        (SUM(f.sales) - LAG(SUM(f.sales)) OVER (PARTITION BY p.category ORDER BY d.year))
        / NULLIF(LAG(SUM(f.sales)) OVER (PARTITION BY p.category ORDER BY d.year), 0) * 100
    , 2) AS crecimiento_yoy_pct
FROM dbo.fact_sales f
JOIN dbo.dim_products p ON f.product_id = p.product_id
JOIN dbo.dim_date d     ON f.date_id     = d.date_id
GROUP BY p.category, d.year
ORDER BY p.category, d.year;
