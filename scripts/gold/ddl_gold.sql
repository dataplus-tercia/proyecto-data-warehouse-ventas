/*
===============================================================================
DDL Script: Crear Vistas (Views) en la Gold Layer
===============================================================================
Propósito del script:
    Este script crea vistas para la Gold Layer en el data warehouse. 
	La Gold Layer presenta la dimension final y la tabla de hechos (Esquema Estrella)
    
    Cada vista realiza transformaciones y combina datos de la Silver Layer
	para producir un conjunto de datos limpio, enriquecido y listo para su uso en el negocio.

Uso:
    -  Estas vistas se pueden consultar directamente para realizar análisis y generar informes.
===============================================================================
*/

-- =============================================================================
-- Crea Dimension: gold.dim_clientes
-- =============================================================================
IF OBJECT_ID('gold.dim_clientes', 'V') IS NOT NULL
    DROP VIEW gold.dim_clientes;
GO

CREATE VIEW gold.dim_clientes AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Surrogate key
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    ci.cst_marital_status              AS marital_status,
	ci.cst_gndr                        AS gender,
    ci.cst_create_date                 AS create_date
FROM silver.erp_cliente_info ci;
GO


-- =============================================================================
-- Crea Dimension: gold.dim_productos
-- =============================================================================
IF OBJECT_ID('gold.dim_productos', 'V') IS NOT NULL
    DROP VIEW gold.dim_productos;
GO

CREATE VIEW gold.dim_productos AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.erp_producto_info pn
WHERE pn.prd_end_dt IS NULL; -- Filter out all historical data
GO

-- =============================================================================
-- Crea Tabla de hechos (fact): gold.fact_ventas
-- =============================================================================
IF OBJECT_ID('gold.fact_ventas', 'V') IS NOT NULL
    DROP VIEW gold.fact_ventas;
GO

CREATE VIEW gold.fact_ventas AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.erp_ventas_detalle sd
LEFT JOIN gold.dim_productos pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_clientes cu
    ON sd.sls_cust_id = cu.customer_id;
GO
