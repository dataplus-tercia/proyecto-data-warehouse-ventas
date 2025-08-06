/*
===============================================================================
Stored Procedure: Cargar Bronze Layer (Fuente -> Bronze)
===============================================================================
Propósito del script:
    Este procedimiento almacenado carga datos en el esquema 'bronze' desde archivos externos CSV. 
    Realiza las siguientes acciones:
    - Trunca las tablas del esquema bronze antes de cargar los datos.
    - Utiliza el comando 'BULK INSERT' para cargar datos desde archivos CSV a tablas del esquema bronze.
	
Parámetros:
    Ninguno. 
	  Este procedimiento almacenado no acepta ningún parámetro ni devuelve ningún valor.

Ejemplo de uso:
    EXEC bronce.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Cargando Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Cargando tablas de SAP';
		PRINT '------------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Tabla: bronze.sap_cliente_info';
		TRUNCATE TABLE bronze.sap_cliente_info;
		PRINT '>> Insertar datos en: bronze.sap_cliente_info';
		BULK INSERT bronze.sap_cliente_info
		FROM 'D:\proyecto_dwh\datasets\source_sap\cliente_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duración de la carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '>> -------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Tabla: bronze.sap_producto_info';
		TRUNCATE TABLE bronze.sap_producto_info;
		PRINT '>> Insertar datos en: bronze.sap_producto_info';
		BULK INSERT bronze.sap_producto_info
		FROM 'D:\proyecto_dwh\datasets\source_sap\producto_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Duración de la carga: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' segundos';
		PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Se completa la carga de la bronze layer';
		PRINT '   - Duración total de la carga: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' segundos';
		PRINT '=========================================='

	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'SE HA PRODUCIDO UN ERROR AL CARGAR LA BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
