{{
  config(
    materialized='table'
  )
}}

with product_agg as (
    select product_id
          ,count(distinct order_id) as order_number
          ,count(distinct user_id) as users_count
          ,sum(order_quantity) as product_ordered
    from {{ ref('stg_greenery__orders') }} o
    group by product_id
)
,
product_dimension as (
    SELECT distinct 
         p.product_id
        ,p.product_name
        ,p.product_price
        ,pa.product_ordered
        ,p.product_inventory
        ,pa.order_number
        ,pa.users_count
        ,round(CAST(p.product_price*pa.product_ordered as numeric),2) as total_amount
    FROM {{ ref('stg_greenery__products') }} p
    left join product_agg pa on p.product_id = pa.product_id
)
select * from product_dimension

-- user can find the product basic information 
