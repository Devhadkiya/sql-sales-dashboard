-- ================================================
-- Retail Sales Dashboard — Schema
-- Run this first in MySQL Workbench
-- ================================================

CREATE DATABASE IF NOT EXISTS retail_sales;
USE retail_sales;

-- customers table
CREATE TABLE IF NOT EXISTS customers (
    customer_id   VARCHAR(10)  PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(100),
    region        VARCHAR(20)  NOT NULL,
    signup_date   DATE
);

-- sales table
CREATE TABLE IF NOT EXISTS sales (
    sale_id       VARCHAR(10)    PRIMARY KEY,
    sale_date     DATE           NOT NULL,
    customer_id   VARCHAR(10)    NOT NULL,
    customer_name VARCHAR(100),
    region        VARCHAR(20)    NOT NULL,
    category      VARCHAR(50)    NOT NULL,
    product_name  VARCHAR(100)   NOT NULL,
    unit_price    DECIMAL(10,2)  NOT NULL,
    quantity      INT            NOT NULL,
    discount      DECIMAL(5,2)   NOT NULL DEFAULT 0,
    revenue       DECIMAL(10,2)  NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);