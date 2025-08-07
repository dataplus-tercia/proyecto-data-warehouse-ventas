/*
===============================================================================
DDL Script: Crea tablas en la Bronze Layer
===============================================================================
Propósito del script:
	Este script crea tablas en el esquema 'bronze', eliminando las tablas existentes 
	si ya estaban creadas.
 
    Ejecute este script para redefinir la estructura DDL de las tablas en el esquema 'bronze'
===============================================================================
*/

IF OBJECT_ID('bronze.erp_cliente_info', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cliente_info;
GO

CREATE TABLE bronze.erp_cliente_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

IF OBJECT_ID('bronze.erp_producto_info', 'U') IS NOT NULL
    DROP TABLE bronze.erp_producto_info;
GO

CREATE TABLE bronze.erp_producto_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);

IF OBJECT_ID('bronze.erp_ventas_detalle', 'U') IS NOT NULL
    DROP TABLE bronze.erp_ventas_detalle;
GO

CREATE TABLE bronze.erp_ventas_detalle (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO
