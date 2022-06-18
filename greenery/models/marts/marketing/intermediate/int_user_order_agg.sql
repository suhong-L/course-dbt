{{ config (
    materialized = 'view'
    , unique_key = 'user_id'
) }}

with  user_purchase_agg as (
    
            select user_id
                  , count(distinct o.order_id) as order_number
                  , sum(order_total_cost) as total_cost
                  , sum(opa.total_product_ordered) as total_product_ordered
                  , min(order_created_at_utc) as first_order_time
                  , max(order_created_at_utc) as last_order_time
                  , round((extract (EPOCH from (max(order_created_at_utc)- min(order_created_at_utc)))/3600)::numeric,1) as order_length_hour            
            from {{ ref('base_greenery__orders') }} o
            left join {{ ref('int_order_product_agg') }} opa on o.order_id = opa.order_id
            group by  user_id
    )
  
    select * from user_purchase_agg