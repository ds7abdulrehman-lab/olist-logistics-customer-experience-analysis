/*
=========================================================
Project:
Olist Supply Chain & Delivery Performance Intelligence

Phase:
03 - Data Profiling

Objective:
Understand the structure, quality, and analytical grain
of order items and customer review data before performing
seller and product category analysis.

Main Tasks:
- Profile order item data
- Check order and item-level relationships
- Identify duplicate or multiple-item orders
- Analyze seller-product relationships
- Profile customer review data
- Check review score distribution
- Identify data quality issues
- Validate the analytical grain for later analysis

Key Focus:
Order Item Analysis and Customer Review Analysis

Author:
Abdul Rehman
=========================================================
*/


use olist_supply_chain;

select *
from olist_order_items_dataset
limit 5;

select order_id, count(order_item_id) as total_items
from olist_order_items_dataset
group by order_id
having total_items > 1;

select  count(distinct order_item_id) as orders
from olist_order_items_dataset;

select order_id, order_item_id, count(order_id) as total_orders
from olist_order_items_dataset
group by order_id, order_item_id
having total_orders > 1;

select price from olist_order_items_dataset
where price < 0;

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight,
    SUM(CASE WHEN freight_value <=0 THEN 1 ELSE 0 END) AS invalid_freight
FROM olist_order_items_dataset;

SELECT COUNT(*) AS null_freight
FROM olist_order_items_dataset
WHERE freight_value IS NULL;

select Min(price) as minimum_price, max(price) as max_price, avg(price) as avg_price, 
min(freight_value) as min_freight, max(freight_value) as max_freight, avg(freight_value) as avg_freight
from olist_order_items_dataset;

select * from olist_order_items_dataset
order by freight_value desc
limit 10;

select *
from olist_order_items_dataset oid
left join olist_orders_dataset od
on oid.order_id = od.order_id
WHERE od.order_id IS NULL;

select *
from olist_order_items_dataset oid
left join olist_products_dataset opd
on oid.product_id = opd.product_id
where opd.product_id is null;

select * 
from olist_order_items_dataset oid
left join olist_sellers_dataset osd
on oid.seller_id = osd.seller_id
where osd.seller_id is null;

#--- Late shipped Order_items ---#

select oid.order_id, oid.order_item_id, oid.product_id, oid.seller_id, oid.shipping_limit_date, od.order_delivered_carrier_date
from olist_order_items_dataset oid
join olist_orders_dataset od
on oid.order_id = od.order_id
Where shipping_limit_date < order_delivered_carrier_date;

#--- top 10 order items by freight-to-price ratio ---#

select * , freight_value / price as freight_to_price_ratio
from olist_order_items_dataset
order by freight_to_price_ratio desc
limit 10;

#--- Inquaring High freight to price ratio for a specific order ---#

select opd.product_id, oid.order_id, opd.product_category_name, opd.product_weight_g, opd.product_length_cm, opd.product_height_cm, opd.product_width_cm
from olist_order_items_dataset oid
join olist_products_dataset opd
on oid.product_id = opd.product_id
having product_id = '8a3254bee785a526d548a81a9bc3c9be';

# --- seeing customer and seller location to investigate high freight price ---#

select oid.order_id, oid.seller_id, osd.seller_city, osd.seller_state,
ocd.customer_id, ocd.customer_city, ocd.customer_state
from olist_order_items_dataset oid
join olist_orders_dataset ood
on oid.order_id = ood.order_id
join olist_customers_dataset ocd
on ocd.customer_id = ood.customer_id
join olist_sellers_dataset osd
on osd.seller_id = oid.seller_id
having order_id ='c5bdd8ef3c0ec420232e668302179113';

#--- Checking all orders containing specific product ---#

select oid.order_id, oid.seller_id, osd.seller_state,
ocd.customer_state, oid.price, oid.freight_value, opd.product_id
from olist_order_items_dataset oid
join olist_orders_dataset ood
on oid.order_id = ood.order_id
join olist_customers_dataset ocd
on ocd.customer_id = ood.customer_id
join olist_sellers_dataset osd
on osd.seller_id = oid.seller_id
join olist_products_dataset opd
on opd.product_id = oid.product_id
where opd.product_id ='8a3254bee785a526d548a81a9bc3c9be';

#--- Total Merchandize value ---#

select sum(price) as total_merchandize_value
from olist_order_items_dataset;

#--- Total Freight cost ---#

 select sum(freight_value) as total_freight_cost
from olist_order_items_dataset;

#--- Freight Percentage of total merchandize value ---#

select sum(price) as total_merchandize_value, sum(freight_value) as total_freight_cost, sum(freight_value)/sum(price) * 100 as freight_merchandize_value
from olist_order_items_dataset;

#--- Product categories driving high freight burden ---#

select opd.product_id, opd.product_category_name, oid.price, oid.freight_value
from olist_products_dataset opd
join olist_order_items_dataset oid
on opd.product_id = oid.product_id;

#--- observing one category freight cost across location of customer and seller ---#

select oid.order_id, oid.seller_id, osd.seller_state,
ocd.customer_state, oid.price, oid.freight_value, opd.product_category_name
from olist_order_items_dataset oid
join olist_orders_dataset ood
on oid.order_id = ood.order_id
join olist_customers_dataset ocd
on ocd.customer_id = ood.customer_id
join olist_sellers_dataset osd
on osd.seller_id = oid.seller_id
join olist_products_dataset opd
on opd.product_id = oid.product_id
where opd.product_category_name ='moveis_decoracao';

#--- product categories create great burden on freight cost ---#

select opd.product_category_name, sum(price) as total_merchandize_value, sum(freight_value) as total_freight_cost, sum(freight_value)/sum(price) * 100 as freight_to_merchandise_ratio
from olist_order_items_dataset oid
join olist_products_dataset opd
on opd.product_id = oid.product_id
group by opd.product_category_name
order by sum(freight_value)/sum(price) * 100 desc
limit 10;

#--- product categories have highest freight cost ---#

select opd.product_category_name, COUNT(*) AS total_items, sum(price) as total_merchandize_value,
 sum(freight_value) as total_freight_cost, AVG(freight_value) AS avg_freight_per_item,
 sum(freight_value)/sum(price) * 100 as freight_to_merchandise_ratio
from olist_order_items_dataset oid
join olist_products_dataset opd
on opd.product_id = oid.product_id
group by opd.product_category_name
order by total_freight_cost desc;

#--- analyzing high freight cost category weight and dimensions to verify reason ---#

select avg(product_weight_g),
avg(product_length_cm),
avg(product_height_cm),
avg(product_width_cm),
avg(freight_value)
from olist_order_items_dataset oid
join olist_products_dataset opd
on opd.product_id = oid.product_id
where opd.product_category_name = 'moveis_decoracao';

select count(*), opd.product_category_name, avg(product_weight_g),
avg(freight_value)
from olist_order_items_dataset oid
join olist_products_dataset opd
on opd.product_id = oid.product_id
group by product_category_name
order by avg(product_weight_g) desc;

select opd.product_category_name, avg(product_weight_g),
avg(freight_value), avg(product_length_cm * product_height_cm * product_width_cm) as average_volume
from olist_order_items_dataset oid
join olist_products_dataset opd
on opd.product_id = oid.product_id
group by product_category_name
Having product_category_name = 'moveis_decoracao';

#--- Product Table Profilign ---#

select
	count(*) as total_products,
    sum(case when product_weight_g is null then 1 else 0 end) as null_weight,
    sum(case when product_length_cm is null then 1 else 0 end) as null_length,
    sum(case when product_height_cm is null then 1 else 0 end) as null_height, 
    sum(case when product_width_cm is null then 1 else 0 end) as null_width
from olist_products_dataset;

select * 
from olist_order_reviews_dataset
limit 10;

select count(*) as total_rows, count(distinct order_id) as total_orders, count(distinct review_id) as total_review
from olist_order_reviews_dataset;

select 
	count(*) as total_count,
	sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when review_score is null then 1 else 0 end) as null_score
from olist_order_reviews_dataset;

select 
	order_id, count(*) as review_count
from olist_order_reviews_dataset
group by review_id, order_id
having count(*) > 1;

SELECT *
FROM olist_order_reviews_dataset
WHERE review_id = '28642ce6250b94cc72bc85960aec6c62';

SELECT
    review_score,
    COUNT(*) AS total_reviews
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;

select avg(review_score) as average_score
from olist_order_reviews_dataset;

select 
	count(*) as all_reviews,
	sum(case when review_score in(1,2) then 1 else 0 end) as disatisfied_reviews,
    sum(case when review_score in(1,2) then 1 else 0 end) / count(*) * 100 as disatisfied_rate
from olist_order_reviews_dataset;

#--Business Analysis---#
#--- Do different order statuses have different customer satisfaction level ---#

select 
	order_status, count(review_id) as total_reviews, avg(review_score) as average_score,
    sum(case when review_score in(1,2) then 1 else 0 end) / count(*) * 100 as disatisfied_rate
from olist_order_reviews_dataset ord
join olist_orders_dataset ood
on ord.order_id = ood.order_id
group by order_status;

#--- which Seller has average lowest reiview ---#

select oid.seller_id, count(*) as total_reviews, avg(review_score) as average_review_score
from olist_order_reviews_dataset ord
join olist_order_items_dataset oid
on ord.order_id = oid.order_id
join olist_sellers_dataset osd
on osd.seller_id = oid.seller_id
group by seller_id
having count(*) >= 50
order by average_review_score asc;
#-- this query didn't work well here, as one seller have multiple order, one order has mutliple items and this analysis at item level so using this query a review will count multiple time--#
#--- So used below query ---#
select seller_id, count(*) as total_reviews, avg(review_score) as average_review_score,
SUM(
    CASE
        WHEN review_score IN (1, 2) THEN 1
        ELSE 0
    END
) / COUNT(*) * 100 AS dissatisfied_rate 
from (
	select distinct oid.seller_id, ord.order_id, ord.review_score
    from olist_order_reviews_dataset ord
    join olist_orders_dataset ood
    on ord.order_id = ood.order_id 
    join olist_order_items_dataset oid
    on ood.order_id = oid.order_id
    Where order_status = 'delivered') as seller_reviews
group by seller_id
having count(*) >= 50
order by dissatisfied_rate desc;

# --- investigation of freight cost of top 5 seller's with poor customer satisfaction ---#

select seller_id, count(*) as total_reviews, 
avg(review_score) as average_review_score,
sum(
	case when review_score in (1,2) then 1 else 0 end
    )/count(review_score) *100 as dissatisfied_rate, count(order_id) as total_item, sum(price) as merchandize_value,
    sum(freight_value) as total_freight_cost, sum(freight_value)/sum(price) *100 as freight_to_merchandise_ratio
from (
	select distinct ord.order_id, oid.seller_id, ord.review_score
    from olist_order_reviews_dataset ord
    join olist_orders_dataset ood
    on ood.order_id = ord.order_id
    join olist_order_items_dataset oid
    on oid.order_id = ood.order_id
    where order_status = 'delivered') as seller_review
join olist_order_items_dataset oid
on oid.seller_id = oid
group by seller_id
having count(*) >= 50;

select 
sr.seller_id,
sr.total_reviews,
sr.average_reviews,
sr.dissatisfied_rate,
sf.total_item, 
sf.merchandize_value, 
sf.total_freight_cost, 
sf.freight_to_merchandise_ratio
from (
	select seller_id, count(*) as total_reviews, avg(review_score) as average_reviews,
    sum( 
		case when review_score in (1,2) then 1
        else 0
			end ) / count(*) *100 as dissatisfied_rate
	from (
		select distinct oid.seller_id, oid.order_id, ord.review_score
        from olist_order_reviews_dataset ord 
        join olist_order_items_dataset oid
        on ord.order_id = oid.order_id
        join olist_orders_dataset ood
        on ood.order_id = oid.order_id
        where order_status = "delivered" 
        ) as seller_reviews
	group by seller_id 
    having count(*) >= 50 
    ) as sr
join (
	select seller_id, count(*) as total_item, sum(price) as merchandize_value,
		sum(freight_value) as total_freight_cost, 
		sum(freight_value)/sum(price) *100 as freight_to_merchandise_ratio
	from olist_order_items_dataset
    group by seller_id ) as sf
on sr.seller_id = sf.seller_id
where sr.seller_id IN (
    '1ca7077d890b907f89be8c954a02686a','2eb70248d66e0e3ef83659f71b244378',
    '972d0f9cf61b499a4812cf0bfa3ad3c4','a49928bcdf77c55c6d6e05e09a9b4ca5',
	'54965bbe3e4f07ae045b90b0b8541f52'
)
order by sr.dissatisfied_rate desc;

select distinct oid.order_id, oid.seller_id, opd.product_category_name, ord.review_score
from olist_order_items_dataset oid
join olist_products_dataset opd
on opd.product_id = oid.product_id
join olist_order_reviews_dataset ord
on ord.order_id = oid.order_id
join olist_orders_dataset ood
on ood.order_id = ord.order_id
where seller_id = "1ca7077d890b907f89be8c954a02686a" and order_status = 'delivered';

select product_category_name, count(*) as total_reviews, avg( review_score) as average_reviews, 
	sum( 
		case when review_score in(1,2) then 1 else 0 
			end) as dissatisfied_reviews,
	sum( 
		case when review_score in (1,2) then 1
        else 0
			end ) / count(*) *100 as dissatisfied_rate
from (
	select distinct oid.order_id, oid.seller_id, opd.product_category_name, ord.review_score
	from olist_order_items_dataset oid
	join olist_products_dataset opd
	on opd.product_id = oid.product_id
	join olist_order_reviews_dataset ord
	on ord.order_id = oid.order_id
	join olist_orders_dataset ood
	on ood.order_id = ord.order_id
	where oid.seller_id = "1ca7077d890b907f89be8c954a02686a" and order_status = 'delivered') as cr
GROUP BY product_category_name
ORDER BY dissatisfied_rate DESC;
    
select count(distinct product_id) as total_products
from olist_products_dataset
where product_category_name = '' ;

SELECT  oid.product_id,
    COUNT(*) AS total_reviews
FROM olist_order_items_dataset oid
JOIN olist_orders_dataset ood
    ON oid.order_id = ood.order_id
JOIN olist_order_reviews_dataset ord
    ON ord.order_id = oid.order_id
JOIN olist_products_dataset opd
    ON opd.product_id = oid.product_id
WHERE oid.seller_id = '1ca7077d890b907f89be8c954a02686a'
  AND opd.product_category_name = ''
  AND ood.order_status = 'delivered'
GROUP BY oid.product_id
ORDER BY total_reviews DESC;

select pr.product_id, count(order_id) as unique_reviewed_orders, avg(review_score) as average_score,
sum( case when review_score in (1,2) then 1 else 0 end) as dissatisfied_reviews,
sum( case when review_score in (1,2) then 1 else 0 end) / count(*) as dissatisfied_rate
from( 
	select distinct opd.product_id, oid.seller_id, ord.order_id, ord.review_score
    from olist_order_reviews_dataset ord
    join olist_orders_dataset ood
    on ord.order_id = ood.order_id 
    join olist_order_items_dataset oid
    on ood.order_id = oid.order_id
    join olist_products_dataset opd
    on opd.product_id = oid.product_id
    Where order_status = 'delivered' and opd.product_id = "b1d207586fca400a2370d50a9ba1da98") as pr
join olist_products_dataset opd
on opd.product_id = pr.product_id 
group by pr.product_id;

select distinct opd.product_id, oid.seller_id, ord.order_id, ord.review_score
    from olist_order_reviews_dataset ord
    join olist_orders_dataset ood
    on ord.order_id = ood.order_id 
    join olist_order_items_dataset oid
    on ood.order_id = oid.order_id
    join olist_products_dataset opd
    on opd.product_id = oid.product_id
    Where order_status = 'delivered' and opd.product_id = "b1d207586fca400a2370d50a9ba1da98";
    
    
