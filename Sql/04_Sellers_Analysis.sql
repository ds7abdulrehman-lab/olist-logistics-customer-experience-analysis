/*
=========================================================
Project:
Olist Supply Chain & Delivery Performance Intelligence

Phase:
04 - Seller Performance & Risk Analysis

Objective:
Identify sellers with delivery and customer satisfaction
risks and prioritize them for operational attention.

Author:
Abdul Rehman
=========================================================
*/

#--- Sellers data Profiling ---#

select
	count(*),
	sum(case when seller_id is null then 1 else 0 end) as null_seller_id,
    sum(case when seller_zip_code_prefix is null then 1 else 0 end) as null_zip,
    sum(case when seller_city is null then 1 else 0 end) as null_city,
    sum(case when seller_state is null then 1 else 0 end) as null_state
from olist_sellers_dataset;

#--- Top 10 sellers by highest freight cost ---#

select
	seller_id, count(*) as total_items, sum(price) as total_merchandize_value,
    sum(freight_value) as total_freight_cost, avg(freight_value) as avg_freight
from olist_order_items_dataset
group by seller_id
order by sum(freight_value) desc
limit 10;

#--- Sellers have high freight relative to the products that they sell ---#

select
	seller_id, count(*) as total_items, sum(price) as total_merchandize_value,
    sum(freight_value) as total_freight_cost, avg(freight_value) as avg_freight,
    SUM(freight_value) / SUM(price) * 100 AS freight_to_merchandise_ratio
from olist_order_items_dataset
group by seller_id
having total_items >= 50
order by freight_to_merchandise_ratio desc;

#--- Sellers with high freight to merchandize ration than market ---#

select
	seller_id, count(*) as total_items, sum(price) as total_merchandize_value,
    sum(freight_value) as total_freight_cost, avg(freight_value) as avg_freight,
    SUM(freight_value) / SUM(price) * 100 AS freight_to_merchandise_ratio,
    (SUM(freight_value) / SUM(price) * 100)- 16.57 as freight_ratio_vs_market
from olist_order_items_dataset
group by seller_id
having total_items >= 50
order by freight_ratio_vs_market desc;

#--- product categories sold by sellers with high freight cost ratio ---#

select 
	opd.product_category_name, oid.seller_id, count(*) as total_items, sum(price) as total_merchandize_value,
    sum(freight_value) as total_freight_cost,
    SUM(freight_value) / SUM(price) * 100 AS freight_to_merchandise_ratio
from olist_order_items_dataset oid
join olist_products_dataset opd
on oid.product_id = opd.product_id
group by oid.seller_id, opd.product_category_name
having oid.seller_id = '8b321bb669392f5163d04c59e235e066';

#--- Specific seller's product dimensions analysis in a specific category to see the reason of high freight ---#

select
	oid.seller_id, opd.product_category_name,
	AVG(product_weight_g),
    AVG(product_length_cm),
    AVG(product_height_cm),
    AVG(product_width_cm),
    AVG(freight_value),
    avg(price)
from olist_order_items_dataset oid
join olist_products_dataset opd
on oid.product_id = opd.product_id
group by oid.seller_id, opd.product_category_name
Having oid.seller_id = '8b321bb669392f5163d04c59e235e066' and opd.product_category_name = 'eletronicos';

select
	count(*) as total_item,
    osd.seller_state, ocd.customer_state, opd.product_category_name,
    avg(freight_value) as average_freight,
    avg(price) as average_price
from olist_order_items_dataset oid
join olist_sellers_dataset osd
on osd.seller_id = oid.seller_id
join olist_orders_dataset ood
on ood.order_id = oid.order_id
join olist_customers_dataset ocd
on ocd.customer_id = ood.customer_id
join olist_products_dataset opd
on opd.product_id = oid.product_id
group by oid.seller_id, opd.product_category_name, osd.seller_state, ocd.customer_state
having oid.seller_id = '8b321bb669392f5163d04c59e235e066' and opd.product_category_name = 'eletronicos';


#-- Sellers Delivery Performance --#

select seller_id, count(*) as seller_order,
sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
else 0 end) as late_orders,
sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
then 1 else 0 end) high_delay_orders,
sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
then 1 else 0 end)/count(*) *100 as high_delay_rate, 
sum(case when review_score in (1,2) then 1 else 0 end) as dissatisfied_customer,
sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 as dissatisfied_rate,
avg(review_score) as customer_satisfaction
from 
	(SELECT DISTINCT
        oid.seller_id,
        oid.order_id,
        ord.review_score,
        oc.clean_delivered_customer_date,
        oc.clean_estimated_delivery_date
	from orders_clean oc
	join olist_order_items_dataset oid
	on oc.order_id = oid.order_id
	join olist_order_reviews_dataset ord
	on ord.order_id = oid.order_id
	WHERE oc.order_status = 'delivered') as seller_order_status
group by seller_id
having count(*) >= 50;

#-- defining threshold for sellers, with average results --#
select 
    min(high_delay_rate) as minimum_delay_rate,
    max(high_delay_rate) as maximum_delay_rate,
    avg(high_delay_rate) as average_delay_rate,
    min(dissatisfied_rate) as minimum_dissatisfied_rate,
    max(dissatisfied_rate) as maximum_dissatisfied_rate,
    avg(dissatisfied_rate) as average_dissatisfied_rate
from (
	select seller_id, count(*) as seller_order,
	sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
	else 0 end) as late_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end) high_delay_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end)/count(*) *100 as high_delay_rate, 
	sum(case when review_score in (1,2) then 1 else 0 end) as dissatisfied_customer,
	sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 as dissatisfied_rate,
	avg(review_score) as customer_satisfaction
	from 
		(SELECT DISTINCT
			oid.seller_id,
			oid.order_id,
			ord.review_score,
			oc.clean_delivered_customer_date,
			oc.clean_estimated_delivery_date
		from orders_clean oc
		join olist_order_items_dataset oid
		on oc.order_id = oid.order_id
		join olist_order_reviews_dataset ord
		on ord.order_id = oid.order_id
		WHERE oc.order_status = 'delivered') as seller_order_status
	group by seller_id
	having count(*) >= 50) as seller_analysis;
    

#-- seller types according to delivery and customer satisfaction---#

select seller_id, count(*) as seller_order,
	sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
	else 0 end) as late_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end) high_delay_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end)/count(*) *100 as high_delay_rate, 
	sum(case when review_score in (1,2) then 1 else 0 end) as dissatisfied_customer,
	sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 as dissatisfied_rate,
	avg(review_score) as customer_satisfaction,
    (case when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Critical_Seller'
        when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Customer/Product_Risk'
		when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'Delivery_Risk'
        when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'stron_performer' 
        end) as seller_segmentation
	from 
		(SELECT DISTINCT
			oid.seller_id,
			oid.order_id,
			ord.review_score,
			oc.clean_delivered_customer_date,
			oc.clean_estimated_delivery_date
		from orders_clean oc
		join olist_order_items_dataset oid
		on oc.order_id = oid.order_id
		join olist_order_reviews_dataset ord
		on ord.order_id = oid.order_id
		WHERE oc.order_status = 'delivered') as seller_order_status
group by seller_id
having count(*) >= 50;


#--- Seller Segmentation ---#

select seller_id, count(*) as seller_order,
	sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
	else 0 end) as late_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end) high_delay_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end)/count(*) *100 as high_delay_rate, 
	sum(case when review_score in (1,2) then 1 else 0 end) as dissatisfied_customer,
	sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 as dissatisfied_rate,
	avg(review_score) as customer_satisfaction,
    (case when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Critical_Seller'
        when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Customer/Product_Risk'
		when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'Delivery_Risk'
        when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'stron_performer' 
        end) as seller_segmentation
	from 
		(SELECT DISTINCT
			oid.seller_id,
			oid.order_id,
			ord.review_score,
			oc.clean_delivered_customer_date,
			oc.clean_estimated_delivery_date
		from orders_clean oc
		join olist_order_items_dataset oid
		on oc.order_id = oid.order_id
		join olist_order_reviews_dataset ord
		on ord.order_id = oid.order_id
		WHERE oc.order_status = 'delivered') as seller_order_status
group by seller_id
having count(*) >= 50;

select seller_segmentation, count(*) as total_sellers, sum(seller_order) as total_orders,
	round(sum(seller_order)/sum(sum(seller_order)) over() * 100, 2) as order_percentage
from (
	select seller_id, count(*) as seller_order,
	sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
	else 0 end) as late_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end) high_delay_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end)/count(*) *100 as high_delay_rate, 
	sum(case when review_score in (1,2) then 1 else 0 end) as dissatisfied_customer,
	sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 as dissatisfied_rate,
	avg(review_score) as customer_satisfaction,
    (case when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Critical_Seller'
        when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Customer/Product_Risk'
		when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'Delivery_Risk'
        when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'stron_performer' 
        end) as seller_segmentation
	from 
		(SELECT DISTINCT
			oid.seller_id,
			oid.order_id,
			ord.review_score,
			oc.clean_delivered_customer_date,
			oc.clean_estimated_delivery_date
		from orders_clean oc
		join olist_order_items_dataset oid
		on oc.order_id = oid.order_id
		join olist_order_reviews_dataset ord
		on ord.order_id = oid.order_id
		WHERE oc.order_status = 'delivered') as seller_order_status
group by seller_id
having count(*) >= 50) as seller_segments
group by seller_segmentation
order by total_orders desc;

#-- Sellers ranking---# 

select 
	seller_id,
    seller_order,
    late_orders,
    high_delay_orders,
    high_delay_rate,
    dissatisfied_customer,
    dissatisfied_rate,
    customer_satisfaction,
    seller_segmentation,

    DENSE_RANK() OVER (
        PARTITION BY seller_segmentation
        ORDER BY dissatisfied_rate DESC
    ) AS risk_rank
from ( 
	select seller_id, count(*) as seller_order,
	sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
	else 0 end) as late_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end) high_delay_orders,
	sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
	then 1 else 0 end)/count(*) *100 as high_delay_rate, 
	sum(case when review_score in (1,2) then 1 else 0 end) as dissatisfied_customer,
	sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 as dissatisfied_rate,
	avg(review_score) as customer_satisfaction,
    (case when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Critical_Seller'
        when sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 >= 13.25 then 'Customer/Product_Risk'
		when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 >= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'Delivery_Risk'
        when  sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
		then 1 else 0 end)/count(*) *100 <= 2.82 
		and sum(case when review_score in (1,2) then 1 else 0 end)/ count(*) * 100 <= 13.25 then 'stron_performer' 
        end) as seller_segmentation
	from 
		(SELECT DISTINCT
			oid.seller_id,
			oid.order_id,
			ord.review_score,
			oc.clean_delivered_customer_date,
			oc.clean_estimated_delivery_date
		from orders_clean oc
		join olist_order_items_dataset oid
		on oc.order_id = oid.order_id
		join olist_order_reviews_dataset ord
		on ord.order_id = oid.order_id
		WHERE oc.order_status = 'delivered') as seller_order_status
	group by seller_id
	having count(*) >= 50) as seller_segments 
order by seller_segmentation,
risk_rank ;