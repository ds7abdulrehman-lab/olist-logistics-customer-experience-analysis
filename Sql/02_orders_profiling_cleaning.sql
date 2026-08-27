/*
=========================================================
Project:
Olist Supply Chain & Delivery Performance Intelligence

Phase:
02 - Data Profiling  and Delivery Performance

Table:
olist_orders_dataset

Objective:
Assess the quality and reliability of the orders table
before performing business analysis.

Author:
Abdul Rehman

=========================================================
*/;

use olist_supply_chain;

select * from olist_orders_dataset
limit 5;

select count(*) as total_orders,
count(distinct order_id) as unique_orders,
count(distinct customer_id) as total_customers
from olist_orders_dataset;

select count(customer_id) as total_customers
from olist_orders_dataset;

select count(order_estimated_delivery_date) as total
from olist_orders_dataset;

select * from olist_orders_dataset
where order_approved_at is null;

select * from olist_orders_dataset
where order_delivered_carrier_date is null;

select * from olist_orders_dataset
where order_delivered_customer_date is null;

select * from olist_orders_dataset
where order_estimated_delivery_date is null;

select * from olist_orders_dataset
where order_purchase_timestamp is null;

SELECT *
FROM olist_orders_dataset
WHERE order_status <> 'delivered'
LIMIT 20; 

SELECT order_status,
       order_delivered_customer_date
FROM olist_orders_dataset
LIMIT 20;

SELECT DISTINCT order_delivered_customer_date
FROM olist_orders_dataset
ORDER BY order_delivered_customer_date
LIMIT 10;

select order_id, order_status, order_delivered_carrier_date, count(*) as total_order
from olist_orders_dataset
group by order_id
having order_status = 'delivered' and order_delivered_carrier_date = '0000
-00-00 00:00:00';

# Date columns have problem "0000-00-00 00:00:00" isn't null so need to fix it.Error 1525 incorrect datetime value

#--- Create clean laayer ---#
DROP VIEW IF EXISTS orders_clean;

CREATE VIEW orders_clean AS
SELECT
    order_id,
    order_status,
    order_approved_at,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE
        WHEN CAST(order_delivered_customer_date AS CHAR) = '0000-00-00 00:00:00'
        THEN NULL
        ELSE order_delivered_customer_date
    END AS clean_delivered_customer_date,

    CASE
        WHEN CAST(order_estimated_delivery_date AS CHAR) = '0000-00-00 00:00:00'
        THEN NULL
        ELSE order_estimated_delivery_date
    END AS clean_estimated_delivery_date
FROM olist_orders_dataset;

SELECT
    order_id,
    clean_delivered_customer_date,
    clean_estimated_delivery_date
FROM orders_clean
WHERE clean_delivered_customer_date IS NULL
LIMIT 20;

#--- Delivery Performance analysis ---#

select 
	order_id,
    clean_delivered_customer_date,
    clean_estimated_delivery_date,
    case when clean_delivered_customer_date > clean_estimated_delivery_date then 'Late'
	when clean_delivered_customer_date <= clean_estimated_delivery_date then 'On Time'
    else 'Not Evaluable' end as Delivery_Performance
from orders_clean;

select
    count(*) as number_of_orders,
    case when clean_delivered_customer_date > clean_estimated_delivery_date then 'Late'
	when clean_delivered_customer_date <= clean_estimated_delivery_date then 'On Time'
    else 'Not Evaluable' end as delivery_performance
from orders_clean
group by delivery_performance;


select
	count(*) total_reviews,
	avg(review_score) as average_review,
    case when clean_delivered_customer_date > clean_estimated_delivery_date then 'Late'
	when clean_delivered_customer_date <= clean_estimated_delivery_date then 'On Time'
    else 'Not Evaluable' end as delivery_performance,
    sum( case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_reviews,
    sum( case when review_score in (1,2) then 1 else 0 end) / count(*) * 100 as dissatisfied_rate
from orders_clean oc
join olist_order_reviews_dataset ord
on oc.order_id = ord.order_id
group by delivery_performance;


select 
    count(distinct oc.order_id) as total_orders,
    count(distinct ord.order_id) as reviewed_orders,
    count(distinct ord.order_id)/ count(distinct oc.order_id) *100 average_review_rate,
    case when clean_delivered_customer_date > clean_estimated_delivery_date then 'Late'
	when clean_delivered_customer_date <= clean_estimated_delivery_date then 'On Time'
    else 'Not Evaluable' end as delivery_performance
    FROM  orders_clean oc
    left join olist_order_reviews_dataset ord
    on ord.order_id = oc.order_id
    group by delivery_performance
    order by 
		case delivery_performance when 'on time' then 1
        when 'Late' then 2
        when 'Not Evaluable' then 3
	end;
    
    select 
		order_id, clean_delivered_customer_date, clean_estimated_delivery_date,
        DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) as delay_days
        from orders_clean
        where clean_delivered_customer_date > clean_estimated_delivery_date
        order by delay_days desc;
        
select count(order_id) as total_orders,
	case when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) = 0 then "normal_dalay"
		when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) between 1 and 3 then 'less_delay'
		when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) in (4,5,6,7) then 'medium_delay'
		else 'High_delay' end as delay_performance
from orders_clean 
where clean_delivered_customer_date > clean_estimated_delivery_date and order_status = 'delivered'
group by delay_performance
;

#--- Measuring 2 kpi's Average_review score and dissatisfied rate, with delivery delays, checking delay vs customer satisfaction.

select count(ord.order_id) as total_orders, avg(review_score) as average_reviews_score,
	sum( case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_reviews,
    sum( case when review_score in (1,2) then 1 else 0 end) / count(*) * 100 as dissatisfied_rate,
	case when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) = 0 then "normal_dalay"
		when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) between 1 and 3 then 'less_delay'
		when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) in (4,5,6,7) then 'medium_delay'
		else 'High_delay' end as delay_performance
from orders_clean oc
join olist_order_reviews_dataset ord
on ord.order_id = oc.order_id
where clean_delivered_customer_date > clean_estimated_delivery_date and order_status = 'delivered'
group by delay_performance;

select state_difference, delay_performance, count(*) as total_order_seller_record
from( 
	select oid.order_id, osd.seller_state, ocd.customer_state,
		case when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) = 0 then "same_day_late"
		when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) between 1 and 3 then 'less_delay'
		when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date) between 4 and 7 then 'medium_delay'
		when DATEDIFF(clean_delivered_customer_date, clean_estimated_delivery_date)  >= 8 then 'high_delay' else 'on_time' end as delay_performance,
	(case when seller_state = customer_state then 'same_state' else 'different_state' end ) as state_difference
	from olist_customers_dataset ocd
	join olist_orders_dataset ood
	on ocd.customer_id = ood.customer_id
	join olist_order_items_dataset oid
	on oid.order_id = ood.order_id
	join olist_sellers_dataset osd
	on osd.seller_id = oid.seller_id
	join orders_clean oc
	on oc.order_id = ood.order_id) as state_delivery_analysis
group by state_difference, delay_performance
order by state_difference, delay_performance;

#percentage calculations#

SELECT
    state_difference,
    delay_performance,
    COUNT(*) AS total_order_seller_records,
    COUNT(*) * 100.0 /
    SUM(COUNT(*)) OVER (
        PARTITION BY state_difference
    ) AS percentage_rate

FROM (
    SELECT
        oid.order_id,
        CASE
            WHEN DATEDIFF(
                clean_delivered_customer_date,
                clean_estimated_delivery_date
            ) = 0 THEN 'same_day_late'
            WHEN DATEDIFF(
                clean_delivered_customer_date,
                clean_estimated_delivery_date
            ) BETWEEN 1 AND 3 THEN 'less_delay'
            WHEN DATEDIFF(
                clean_delivered_customer_date,
                clean_estimated_delivery_date
            ) BETWEEN 4 AND 7 THEN 'medium_delay'
            WHEN DATEDIFF(
                clean_delivered_customer_date,
                clean_estimated_delivery_date
            ) >= 8 THEN 'high_delay'
            ELSE 'on_time'
        END AS delay_performance,
        CASE
            WHEN osd.seller_state = ocd.customer_state
                THEN 'same_state'
            ELSE 'different_state'
        END AS state_difference
    FROM olist_customers_dataset ocd
    JOIN olist_orders_dataset ood
        ON ocd.customer_id = ood.customer_id
    JOIN olist_order_items_dataset oid
        ON oid.order_id = ood.order_id
    JOIN olist_sellers_dataset osd
        ON osd.seller_id = oid.seller_id
    JOIN orders_clean oc
        ON oc.order_id = ood.order_id
) AS state_delivery_analysis
GROUP BY
    state_difference,
    delay_performance
ORDER BY
    state_difference,
    delay_performance;
    
# Sellers late delivery rate #

select oid.seller_id, count(*) as seller_order,
sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
else 0 end) as late_orders,
sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
else 0 end)/ count(*)*100 as late_delivery_rate
from orders_clean oc
join olist_order_items_dataset oid
on oc.order_id = oid.order_id
group by seller_id
having count(*) >= 50
order by late_delivery_rate desc;

#identification of sever delay sellers#

select oid.seller_id, count(*) as seller_order,
sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
else 0 end) as late_orders,
sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
else 0 end)/ count(*)*100 as late_delivery_rate,
sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
then 1 else 0 end) high_delay_orders,
sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
then 1 else 0 end)/count(*) *100 as high_delay_rate
from orders_clean oc
join olist_order_items_dataset oid
on oc.order_id = oid.order_id
WHERE oc.order_status = 'delivered'
group by seller_id
having count(*) >= 50 
order by high_delay_rate desc;

#--- sever late sellers customer satisfaction ---#

select seller_id, count(*) as seller_order,
sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
else 0 end) as late_orders,
sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
then 1 else 0 end) high_delay_orders,
sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
then 1 else 0 end)/count(*) *100 as high_delay_rate, 
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
having count(*) >= 50 
order by high_delay_rate desc;


#--- sellers with dissatisfied rate--#

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
having count(*) >= 50 
order by high_delay_rate desc;

#--- Seller's category analysis to see customer dissatisfaction

select seller_id, product_category_name, count(*) as total_orders, product_id,
avg(review_score) as customer_satisfaction
from 
	(SELECT DISTINCT
		opd.product_id,
		opd.product_category_name,
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
    join olist_products_dataset opd
    on opd.product_id = oid.product_id
	WHERE oc.order_status = 'delivered' and seller_id ='95f83f51203c626648c875dd41874c7f') as spc
group by seller_id, product_category_name, product_id;
