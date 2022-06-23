{{ config(
    materialized = 'view'
) }}

with order_product_agg as(
    select order_id
          ,count(distinct product_id) as product_count
          ,sum(order_quantity) as total_product_ordered
    from {{ ref('stg_greenery__order_items') }}
    group by order_id
)
select * from order_product_agg
