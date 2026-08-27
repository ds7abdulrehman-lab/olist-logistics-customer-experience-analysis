# Data

## Dataset

This project uses the **Brazilian E-Commerce Public Dataset by Olist**.

The dataset contains real anonymized e-commerce transactions from multiple marketplaces in Brazil. It includes information about orders, customers, sellers, products, payments, reviews, and geolocation.

The raw dataset is not included in this repository because of GitHub file upload and repository size limitations.

## Main Files Used

The analysis was built using the following Olist datasets:

- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_geolocation_dataset.csv`
- `product_category_name_translation.csv`

## How the Data Was Used

The data was processed and analyzed across different stages of the project:

- **SQL** was used for data exploration, joins, cleaning, and analytical queries.
- **Python** was used for exploratory data analysis and deeper investigation.
- **Power BI** was used to build the interactive dashboard and visualize business performance.
- The analysis focused on delivery performance, customer satisfaction, freight costs, product categories, and seller risk.

## Data Preparation

Raw datasets were cleaned and combined to create analytical metrics such as:

- Delivery delay categories
- On-time delivery rate
- Customer satisfaction and dissatisfaction rate
- Seller risk segmentation
- Freight-to-product price ratio
- Product category dissatisfaction analysis
- Customer satisfaction trends over time

## Note

The original raw data should be downloaded from the official Olist public dataset source before running the SQL queries, notebooks, or rebuilding the Power BI analysis.

The folder structure should remain consistent with the files referenced in the SQL, Python, and Power BI components of this project.
