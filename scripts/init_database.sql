/*

=============================================================
Crear Base de Datos y Esquemas
=============================================================
Propósito del script:
    Este script crea una nueva base de datos llamada 'ComercialDWProd' después de verificar si ya existe.
    Si la base de datos existe, se elimina y se vuelve a crear. Además, el script configura tres esquemas
    dentro de la base de datos: 'bronze', 'silver' y 'gold'.
	
ADVERTENCIA:
    La ejecución de este script eliminará toda la base de datos 'ComercialDWProd' si existe.
    Todos los datos de la base de datos se eliminarán permanentemente. Proceda con precaución
    y asegúrese de tener copias de seguridad adecuadas antes de ejecutar este script.

*/


USE master;
GO

-- Eliminar y volver a crear la base de datos 'ComercialDWProd'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'ComercialDWProd')
BEGIN
    ALTER DATABASE ComercialDWProd SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ComercialDWProd;
END;
GO

-- Crear la Base de Datos 'ComercialDWProd'
CREATE DATABASE ComercialDWProd;
GO

USE ComercialDWProd;
GO

-- Crear Esquemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO