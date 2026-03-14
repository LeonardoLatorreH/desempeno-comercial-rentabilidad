-- Tablas base para el análisis de desempeño comercial y rentabilidad.
-- Estructura de esquema estrella: una tabla de hechos y tres dimensiones.

IF OBJECT_ID('dbo.fact_sales', 'U')    IS NOT NULL DROP TABLE dbo.fact_sales;
IF OBJECT_ID('dbo.dim_products', 'U')  IS NOT NULL DROP TABLE dbo.dim_products;
IF OBJECT_ID('dbo.dim_customers', 'U') IS NOT NULL DROP TABLE dbo.dim_customers;
IF OBJECT_ID('dbo.dim_date', 'U')      IS NOT NULL DROP TABLE dbo.dim_date;


CREATE TABLE dbo.dim_customers (
    customer_id   VARCHAR(20)  NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    segment       VARCHAR(50)  NOT NULL,
    country       VARCHAR(50)  NOT NULL,
    city          VARCHAR(100) NOT NULL,
    state         VARCHAR(100) NOT NULL,
    region        VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_dim_customers PRIMARY KEY (customer_id)
);


CREATE TABLE dbo.dim_products (
    product_id   VARCHAR(50)  NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category     VARCHAR(50)  NOT NULL,
    sub_category VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_dim_products PRIMARY KEY (product_id)
);


-- Dimensión de fecha para análisis temporal en Power BI
CREATE TABLE dbo.dim_date (
    date_id    INT         NOT NULL,
    full_date  DATE        NOT NULL,
    year       INT         NOT NULL,
    quarter    INT         NOT NULL,
    month      INT         NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    week       INT         NOT NULL,
    day        INT         NOT NULL,
    CONSTRAINT PK_dim_date PRIMARY KEY (date_id)
);


-- Tabla de hechos: una fila por línea de pedido
CREATE TABLE dbo.fact_sales (
    row_id      INT           NOT NULL,
    order_id    VARCHAR(20)   NOT NULL,
    date_id     INT           NOT NULL,
    ship_date   DATE          NOT NULL,
    ship_mode   VARCHAR(50)   NOT NULL,
    customer_id VARCHAR(20)   NOT NULL,
    product_id  VARCHAR(50)   NOT NULL,
    sales       DECIMAL(10,2) NOT NULL,
    quantity    INT           NOT NULL,
    discount    DECIMAL(4,2)  NOT NULL,
    profit      DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_fact_sales     PRIMARY KEY (row_id),
    CONSTRAINT FK_fact_customers FOREIGN KEY (customer_id) REFERENCES dbo.dim_customers(customer_id),
    CONSTRAINT FK_fact_products  FOREIGN KEY (product_id)  REFERENCES dbo.dim_products(product_id),
    CONSTRAINT FK_fact_date      FOREIGN KEY (date_id)     REFERENCES dbo.dim_date(date_id)
);
