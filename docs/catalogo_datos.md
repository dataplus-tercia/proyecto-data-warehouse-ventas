# Catalogo de Datos para Gold Layer

## Descripción general
La capa Gold es la representación de datos a nivel empresarial, estructurada para dar soporte a casos de uso analíticos y de generación de informes. Se compone de **tablas de dimensiones** y **tablas de hechos** para métricas empresariales específicas.

---

### 1. **gold.dim_clientes**
- **Proposito:** Almacena los datos de los clientes.
- **Columnas:**

| Nombre columna   | Tipo de dato  | Descripcion                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key     | INT           | Clave sustituta que identifica de forma única cada registro de cliente en la tabla de dimensiones.    |
| customer_id      | INT           | Identificador numérico único asignado a cada cliente.                                                 |
| customer_number  | NVARCHAR(50)  | Identificador alfanumérico que representa al cliente, utilizado para el seguimiento y la referencia.  |
| first_name       | NVARCHAR(50)  | El nombre del cliente, tal y como figura en el sistema.                                               |
| last_name        | NVARCHAR(50)  | El apellido o nombre de familia del cliente.                                                          |
| marital_status   | NVARCHAR(50)  | El estado civil del cliente (por ejemplo, 'Married', 'Single').                                       |
| gender           | NVARCHAR(50)  | El sexo del cliente (por ejemplo, 'Male', 'Female', 'n/a').                                           |
| create_date      | DATE          | La fecha y hora en que se creó el registro del cliente en el sistema.                                 |

---

### 2. **gold.dim_productos**
- **Proposito:** Proporciona información sobre los productos y sus características.
- **Columnas:**

| Nombre columna      | Tipo de dato  | Descripcion                                                                                   |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_key         | INT           | Clave sustituta que identifica de forma única cada registro de producto en la tabla de dimensiones de productos.     |
| product_id          | INT           | Identificador único asignado al producto para su seguimiento y referencia internos.                                  |
| product_number      | NVARCHAR(50)  | Código alfanumérico estructurado que representa el producto, utilizado a menudo para su categorización o inventario. |
| product_name        | NVARCHAR(50)  | Nombre descriptivo del producto, que incluye detalles clave como el tipo, el color y el tamaño.                      |
| category_id         | NVARCHAR(50)  | Identificador único de la categoría del producto, vinculado a su clasificación de alto nivel.                        |
| cost                | INT           | Coste o precio base del producto, medido en unidades monetarias.                                                     |
| product_line        | NVARCHAR(50)  | Línea o serie específica a la que pertenece el producto (por ejemplo, Road, Mountain).                               |
| start_date          | DATE          | Fecha en la que el producto salió a la venta o se pudo empezar a utilizar                                            |

---

### 3. **gold.fact_ventas**
- **Purpose:** Almacena datos de ventas transaccionales con fines analíticos.
- **Columns:**

| Nombre columna  | Tipo de dato  | Descripcion                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | Un identificador alfanumérico único para cada pedido de venta (por ejemplo, «SO54496»).                |
| product_key     | INT           | Clave sustituta que vincula el pedido con la tabla de dimensiones del producto.                        |
| customer_key    | INT           | Clave sustituta que vincula el pedido con la tabla de dimensiones del cliente.                         |
| order_date      | DATE          | La fecha en la que se realizó el pedido.                                                               |
| shipping_date   | DATE          | La fecha en la que se envió el pedido al cliente.                                                      |
| due_date        | DATE          | La fecha de vencimiento del pago del pedido.                                                           |
| sales_amount    | INT           | El valor monetario total de la venta de la partida, en unidades monetarias enteras (por ejemplo, 25).  |
| quantity        | INT           | El número de unidades del producto solicitado para la partida (por ejemplo, 1).                        |
| price           | INT           | El precio por unidad del producto para la partida, en unidades monetarias enteras (por ejemplo, 25).   |
