/*
=========================================================
Project:
Olist Supply Chain & Delivery Performance Intelligence

Phase:
05 - Product Category Performance Analysis

Objective:
Identify product categories creating customer
dissatisfaction and prioritize improvement opportunities.

Author:
Abdul Rehman
=========================================================
*/


use olist_supply_chain;

#-- Categpry performance analysis ---#

select count(*) as total_orders, avg(review_score) as average_review_score,
sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate
from (
	select distinct
        oid.order_id,
        ord.review_score,
        oc.clean_delivered_customer_date,
        oc.clean_estimated_delivery_date,
        opd.product_category_name
	from orders_clean oc
	join olist_order_items_dataset oid
	on oc.order_id = oid.order_id
	join olist_order_reviews_dataset ord
	on ord.order_id = oid.order_id
    join olist_products_dataset opd
    on opd.product_id = oid.product_id
    where order_status = 'delivered') as product_details
group by product_category_name
having count(*) >= 50
order by dissatisfied_rate desc;

#-- Finding periority category for analysis-- #
# average dissatisfaction rate #
select 
	avg(dissatisfied_rate) as average_dissatisfaction,
    avg(average_reviews_score) as category_average_score
from (
		select count(*) as total_orders, avg(review_score) as average_reviews_score,
	sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
	sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate
	from (
		select distinct
			oid.order_id,
			ord.review_score,
			oc.clean_delivered_customer_date,
			oc.clean_estimated_delivery_date,
			opd.product_category_name
		from orders_clean oc
		join olist_order_items_dataset oid
		on oc.order_id = oid.order_id
		join olist_order_reviews_dataset ord
		on ord.order_id = oid.order_id
		join olist_products_dataset opd
		on opd.product_id = oid.product_id
		where order_status = 'delivered') as product_details
	group by product_category_name
	having count(*) >= 50) as category_statistics
;

#--- Segmentation of Categories ---#

select 
	product_category_name, 
    average_review_score, 
    dissatisfied_customer, 
    dissatisfied_rate,
    category_segments
from (
		select product_category_name, count(*) as total_orders, avg(review_score) as average_review_score,
	sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
	sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
    case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
		and avg(review_score) < 4.14 then 'critical_category'
		when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
		and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
		when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
		and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
	end as category_segments
	from (
		select distinct
			oid.order_id,
			ord.review_score,
			oc.clean_delivered_customer_date,
			oc.clean_estimated_delivery_date,
			opd.product_category_name
		from orders_clean oc
		join olist_order_items_dataset oid
		on oc.order_id = oid.order_id
		join olist_order_reviews_dataset ord
		on ord.order_id = oid.order_id
		join olist_products_dataset opd
		on opd.product_id = oid.product_id
		where order_status = 'delivered') as product_details
	group by product_category_name
	having count(*) >= 50) as categry_segmentation 
;

select category_segments, count(*) as total_categories, 
	sum(total_orders) as total_category_orders,
    round(sum(total_orders)/sum(sum(total_orders)) over () * 100 ,2) as percentage_orders
from (
		select 
        total_orders,
		product_category_name, 
		average_review_score, 
		dissatisfied_customer, 
		dissatisfied_rate,
		category_segments
        
	from (
			select product_category_name, count(*) as total_orders, avg(review_score) as average_review_score,
		sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
		sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
		case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
			and avg(review_score) < 4.14 then 'critical_category'
			when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
			and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
			when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
			and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
		end as category_segments
		from (
			select distinct
				oid.order_id,
				ord.review_score,
				oc.clean_delivered_customer_date,
				oc.clean_estimated_delivery_date,
				opd.product_category_name
			from orders_clean oc
			join olist_order_items_dataset oid
			on oc.order_id = oid.order_id
			join olist_order_reviews_dataset ord
			on ord.order_id = oid.order_id
			join olist_products_dataset opd
			on opd.product_id = oid.product_id
			where order_status = 'delivered') as product_details
		group by product_category_name
		having count(*) >= 50) as categry_segmentation) as segmented_categories
group by category_segments;


#-- Critical category ranking -- #

select
	product_category_name,
    category_segments,
	total_orders,
    dissatisfied_rate,
    DENSE_RANK() over(PARTITION BY category_segments
ORDER BY dissatisfied_rate DESC) as dissatisfaction_rank
			
		from (
				select product_category_name, count(*) as total_orders, avg(review_score) as average_review_score,
			sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
			sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
			case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) < 4.14 then 'critical_category'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
				and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
			end as category_segments
			from (
				select distinct
					oid.order_id,
					ord.review_score,
					oc.clean_delivered_customer_date,
					oc.clean_estimated_delivery_date,
					opd.product_category_name
				from orders_clean oc
				join olist_order_items_dataset oid
				on oc.order_id = oid.order_id
				join olist_order_reviews_dataset ord
				on ord.order_id = oid.order_id
				join olist_products_dataset opd
				on opd.product_id = oid.product_id
				where order_status = 'delivered') as product_details
			group by product_category_name
			having count(*) >= 50) as categry_segmentation;
            

select dissatisfied_rate, total_orders, product_category_name, category_segments
from(
	select product_category_name, count(*) as total_orders, avg(review_score) as average_review_score,
			sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
			sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
			case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) < 4.14 then 'critical_category'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
				and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
			end as category_segments
			from (
				select distinct
					oid.order_id,
					ord.review_score,
					oc.clean_delivered_customer_date,
					oc.clean_estimated_delivery_date,
					opd.product_category_name
				from orders_clean oc
				join olist_order_items_dataset oid
				on oc.order_id = oid.order_id
				join olist_order_reviews_dataset ord
				on ord.order_id = oid.order_id
				join olist_products_dataset opd
				on opd.product_id = oid.product_id
				where order_status = 'delivered') as product_details
			group by product_category_name
			having count(*) >= 50) as categry_segmentation
where category_segments = 'critical_category';

select  
	product_category_name,
	total_orders,
	dissatisfied_customer,
	dissatisfied_rate,
	dense_rank() over(order by dissatisfied_customer desc) as business_priority_rank
from(
	select product_category_name, count(*) as total_orders, avg(review_score) as average_review_score,
			sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
			sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
			case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) < 4.14 then 'critical_category'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
				and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
			end as category_segments
			from (
				select distinct
					oid.order_id,
					ord.review_score,
					oc.clean_delivered_customer_date,
					oc.clean_estimated_delivery_date,
					opd.product_category_name
				from orders_clean oc
				join olist_order_items_dataset oid
				on oc.order_id = oid.order_id
				join olist_order_reviews_dataset ord
				on ord.order_id = oid.order_id
				join olist_products_dataset opd
				on opd.product_id = oid.product_id
				where order_status = 'delivered') as product_details
			group by product_category_name
			having count(*) >= 50) as categry_segmentation
where category_segments = 'critical_category';

select  
	product_category_name,
	total_orders,
	dissatisfied_customer,
	dissatisfied_rate,
    late_orders, high_delay_orders, high_delay_rate,
	dense_rank() over(order by dissatisfied_customer desc) as business_priority_rank
from(
	select product_category_name, count(*) as total_orders, avg(review_score) as average_review_score,
			sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
			sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
			sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
			else 0 end) as late_orders,
			sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
			then 1 else 0 end) high_delay_orders,
			sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
			then 1 else 0 end)/count(*) *100 as high_delay_rate,
            case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) < 4.14 then 'critical_category'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
				and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
			end as category_segments
			from (
				select distinct
					oid.order_id,
					ord.review_score,
					oc.clean_delivered_customer_date,
					oc.clean_estimated_delivery_date,
					opd.product_category_name
				from orders_clean oc
				join olist_order_items_dataset oid
				on oc.order_id = oid.order_id
				join olist_order_reviews_dataset ord
				on ord.order_id = oid.order_id
				join olist_products_dataset opd
				on opd.product_id = oid.product_id
				where order_status = 'delivered') as product_details
			group by product_category_name
			having count(*) >= 50) as categry_segmentation
where category_segments = 'critical_category';


#--- Category freight cost---#

select  
	product_category_name,
    average_freight_value,
	average_product_price,
	category_segments,
	total_orders,
    freight_burden,
	dissatisfied_rate,
	dense_rank() over(order by dissatisfied_customer desc) as business_priority_rank
from(
	select 
    avg(freight_value) as average_freight_value, avg(price) as average_product_price,
    SUM(freight_value) / SUM(price) * 100 as freight_burden,
    product_category_name,
    count(*) as total_orders, avg(review_score) as average_review_score,
			sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
			sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
            case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) < 4.14 then 'critical_category'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
				and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
			end as category_segments
			from (
				select distinct
					oid.order_id,
                    oid.freight_value,
                    oid.price,
					ord.review_score,
					oc.clean_delivered_customer_date,
					oc.clean_estimated_delivery_date,
					opd.product_category_name
				from orders_clean oc
				join olist_order_items_dataset oid
				on oc.order_id = oid.order_id
				join olist_order_reviews_dataset ord
				on ord.order_id = oid.order_id
				join olist_products_dataset opd
				on opd.product_id = oid.product_id
				where order_status = 'delivered') as product_details
	group by product_category_name
			having count(*) >= 50) as categry_segmentation
where category_segments = 'strong_category';

#-- Category freight cost and delivery performance by segmentation---#

select  
	product_category_name,
    average_freight_value,
	average_product_price,
	category_segments,
	total_orders,
    freight_burden,
	dissatisfied_rate, late_orders, high_delay_orders, high_delay_rate,
	dense_rank() over(order by dissatisfied_customer desc) as business_priority_rank
from(
	select 
    avg(freight_value) as average_freight_value, avg(price) as average_product_price,
    SUM(freight_value) / SUM(price) * 100 as freight_burden,
    product_category_name,
    count(*) as total_orders, avg(review_score) as average_review_score,
			sum(case when review_score in (1,2) then 1 else 0 end ) as dissatisfied_customer,
			sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 as dissatisfied_rate,
            sum(case when clean_delivered_customer_date > clean_estimated_delivery_date then 1
			else 0 end) as late_orders,
			sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
			then 1 else 0 end) high_delay_orders,
			sum( case when datediff(clean_delivered_customer_date, clean_estimated_delivery_date) >= 8
			then 1 else 0 end)/count(*) *100 as high_delay_rate,
            case when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) < 4.14 then 'critical_category'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 > 12.70
				and avg(review_score) >= 4.14 then 'dissatisfaction_risk'
				when sum(case when review_score in (1,2) then 1 else 0 end )/count(*) * 100 <= 12.70
				and avg(review_score) < 4.14 then 'low_satisfaction' else 'strong_category' 
			end as category_segments
			from (
				select distinct
					oid.order_id,
                    oid.freight_value,
                    oid.price,
					ord.review_score,
					oc.clean_delivered_customer_date,
					oc.clean_estimated_delivery_date,
					opd.product_category_name
				from orders_clean oc
				join olist_order_items_dataset oid
				on oc.order_id = oid.order_id
				join olist_order_reviews_dataset ord
				on ord.order_id = oid.order_id
				join olist_products_dataset opd
				on opd.product_id = oid.product_id
				where order_status = 'delivered') as product_details
	group by product_category_name
			having count(*) >= 50) as categry_segmentation
where category_segments = 'critical_category';