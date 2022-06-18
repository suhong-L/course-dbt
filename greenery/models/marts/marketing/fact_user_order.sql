{{ config (
    materialized = 'table'
) }}

with order_status_agg as (
    {% set order_status_list = ["shipped", "preparing", "delivered"] %}
    select user_id
           {% for order_status in order_status_list %}
           ,sum(case order_status when '{{order_status}}' then 1 else 0 end) as {{order_status}}_order
           {% endfor %}
        --    ,sum(case order_status when 'preparing' then 1 else 0 end) as preparing_order
        --    ,sum(case order_status when 'delivered' then 1 else 0 end) as delivered_order
    from {{ ref('base_greenery__orders') }} o 
    group by user_id 
)

,
avg_delivery_time as (
    select user_id
          ,count(distinct order_id) as delivered_orders
          ,sum(delivery_time_days) as delivery_time_days
          ,sum(delivery_time_days)/count(distinct order_id) as avg_delivery_days
     from {{ ref('int_order_delivery_agg') }}
    group by user_id
)

,
user_order_source as (
    select uoa.user_id
         , uoa.order_number
         , round(cast( uoa.total_cost as numeric),2) as total_cost
         , total_product_ordered
         , round(cast(total_cost/order_number as numeric), 2) as avg_cost_per_order
         , first_order_time
         , last_order_time
         , order_length_hour 
         , round(cast(order_length_hour/order_number as numeric),2) as avg_hour_between_orders
         , (CURRENT_DATE - (last_order_time::date)) as days_since_last_purchase
         , osa.shipped_order
         , osa.preparing_order
         , osa.delivered_order
         , round(cast(avg_delivery_days as numeric),2) as avg_delivery_days
    from {{ ref('int_user_order_agg') }} uoa 
    left join order_status_agg osa on osa.user_id = uoa.user_id
    left join avg_delivery_time adt on adt.user_id = uoa.user_id
    
)
select * from user_order_source
order by order_number DESC