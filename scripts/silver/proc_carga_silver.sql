/*
===============================================================================
Stored Procedure: Cargar Silver Layer (bronze -> Silver)
===============================================================================
Propósito del script:
	Este procedimiento almacenado realiza el proceso ETL (Extraer, Transformar, Cargar) para
    llenar las tablas del esquema 'silver' desde el esquema 'bronze'.
	Acciones realizadas:
		- Trunca las tablas del esquema silver.
		- Inserta datos transformados y depurados de las tablas del esquema bronze en las tablas del esquema silver.
		
Parámetros:
    Ninguno. 
	  Este procedimiento almacenado no acepta ningún parámetro ni devuelve ningún valor.

Ejemplo de uso:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.carga_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Cargando Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Cargando tablas de erp';
		PRINT '------------------------------------------------';

		-- Cargando silver.erp_cliente_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cliente_info';
		TRUNCATE TABLE silver.erp_cliente_info;
		PRINT '>> Insertar datos en: silver.erp_cliente_info';
		INSERT INTO silver.erp_cliente_info (
			cst_id, 
			cst_key, 
			cst_firstname, 
			cst_lastname, 
			cst_marital_status, 
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status, -- Normalize marital status values to readable format
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, -- Normalize gender values to readable format
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.erp_cliente_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1; -- Select the most recent record per customer
		SET @end_time = GETDATE();
        PRINT '>> Duración de la carga: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

		-- Carga silver.erp_producto_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_producto_info';
		TRUNCATE TABLE silver.erp_producto_info;
		PRINT '>> Insertar datos en: silver.erp_producto_info';
		INSERT INTO silver.erp_producto_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract category ID
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extract product key
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE 
				WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
				WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
				WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
				WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line, -- Map product line codes to descriptive values
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			CAST(
				LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
				AS DATE
			) AS prd_end_dt -- Calculate end date as one day before the next start date
		FROM bronze.erp_producto_info;
        SET @end_time = GETDATE();
        PRINT '>> Duración de la carga: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';

        -- Cargando erp_ventas_detalle
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_ventas_detalle';
		TRUNCATE TABLE silver.erp_ventas_detalle;
		PRINT '>> Insertar datos en: silver.erp_ventas_detalle';
		INSERT INTO silver.erp_ventas_detalle (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE 
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
					THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
			sls_quantity,
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0 
					THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price  -- Derive price if original value is invalid
			END AS sls_price
		FROM bronze.erp_ventas_detalle;
        SET @end_time = GETDATE();
        PRINT '>> Duración de la carga: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' segundos';
        PRINT '>> -------------';



		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Se completa la carga de la silver layer';
        PRINT '   - Duración total de la carga: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'SE HA PRODUCIDO UN ERROR AL CARGAR LA SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
