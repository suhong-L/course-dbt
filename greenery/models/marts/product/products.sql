{{
  config(
    materialized='table'
  )
}}

with product_order_agg as (
    select product_id
          ,count(distinct o.order_id) as order_number
          ,count(distinct user_id) as users_count
          ,sum(order_quantity) as product_ordered
    from {{ ref('stg_greenery__orders') }} o 
    left join {{ ref('stg_greenery__order_items') }} oi on o.order_id = oi.order_id
    group by product_id
)
,
product_session_agg as (
    select product_id
          ,count(distinct e.session_id) as total_session
          ,sum(case when event_type = 'add_to_cart' then 1 else 0 end) as checkout_session
          ,sum(case when event_type = 'add_to_cart' and e1.session_id is not Null then 1 else 0 end) as purchase_session
    from {{ ref('stg_greenery__events') }} e
    left join (select distinct session_id from {{ ref('stg_greenery__events') }} where event_type = 'checkout')e1 on e.session_id = e1.session_id
    group by product_id
)
,
product_agg as (
    SELECT distinct 
         p.product_id
        ,p.product_name
        ,product_price::numeric(16,2) as product_price
        ,poa.product_ordered
        ,p.product_inventory
        ,poa.order_number
        ,poa.users_count
        ,round(cast(p.product_price*poa.product_ordered as numeric),2) as total_amount
        ,psa.total_session
        ,psa.checkout_session
        ,psa.purchase_session
        , {{ get_ratio_percentage('purchase_session', 'total_session')}} as conversion_rate_percentage
    FROM {{ ref('stg_greenery__products') }} p
    left join product_order_agg poa on p.product_id = poa.product_id
    left join product_session_agg psa on p.product_id = psa.product_id
)
select * from product_agg

