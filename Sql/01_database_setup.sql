/*
=========================================================
Project:
Olist Supply Chain & Delivery Performance Intelligence

Phase:
01 - Database Setup

Objective:
Create the Olist analytical database and prepare the
required tables for supply chain, delivery, seller,
customer, product, and review analysis.

Main Tasks:
- Create database
- Import Olist datasets
- Review table structure
- Prepare the database environment for analysis

Author:
Abdul Rehman
=========================================================
*/

DROP TABLE IF EXISTS olist_orders_dataset;

CREATE TABLE olist_orders_dataset (
    order_id VARCHAR(50) NOT NULL,
    customer_id VARCHAR(50) NOT NULL,
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,

    PRIMARY KEY (order_id)
);

show tables;
DESCRIBE olist_orders_dataset;
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
);
SELECT COUNT(*)
FROM olist_orders_dataset;

SHOW WARNINGS;

TRUNCATE TABLE olist_orders_dataset;

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_orders_dataset.csv'
INTO TABLE olist_orders_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
);

show warnings;

select count(*) total_orders
from olist_orders_dataset;

DROP TABLE IF EXISTS olist_customers_dataset;

CREATE TABLE olist_customers_dataset (
    customer_id VARCHAR(50) NOT NULL,
    customer_unique_id VARCHAR(50) NOT NULL,
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state CHAR(2),

    PRIMARY KEY (customer_id)
);

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_customers_dataset.csv'
INTO TABLE olist_customers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) as total_customers
from olist_customers_dataset;

DROP TABLE IF EXISTS olist_order_items_dataset;

CREATE TABLE olist_order_items_dataset (
    order_id VARCHAR(50) NOT NULL,
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_order_items_dataset.csv'
INTO TABLE olist_order_items_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) total_order_item
from olist_order_items_dataset;

DROP TABLE IF EXISTS olist_order_reviews_dataset;

CREATE TABLE olist_order_reviews_dataset (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);
LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) as total_reviews
from olist_order_reviews_dataset;

DROP TABLE IF EXISTS olist_order_payments_dataset;

CREATE TABLE olist_order_payments_dataset (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(10,2)
);

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) as total_order_payments
from olist_order_payments_dataset;

DROP TABLE IF EXISTS olist_products_dataset;

CREATE TABLE olist_products_dataset (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT,

    PRIMARY KEY(product_id)
);

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_products_dataset.csv'
INTO TABLE olist_products_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) as total_rows
from olist_products_dataset;

show tables;
DROP TABLE IF EXISTS olist_sellers_dataset;

CREATE TABLE olist_sellers_dataset (
    seller_id VARCHAR(50),
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state CHAR(2),

    PRIMARY KEY(seller_id)
);

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_sellers_dataset.csv'
INTO TABLE olist_sellers_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) as total_products
from olist_sellers_dataset;

DROP TABLE IF EXISTS olist_geolocation_dataset;

CREATE TABLE olist_geolocation_dataset (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/olist_geolocation_dataset.csv'
INTO TABLE olist_geolocation_dataset
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * 
from olist_geolocation_dataset
limit 5;
show tables;

select count(*) as total
from olist_geolocation_dataset;

DROP TABLE IF EXISTS product_category_name_translation;

CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'F:/Data Science/olistst_supply_chain/Data/raw/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) as total_products
from product_category_name_translation;
