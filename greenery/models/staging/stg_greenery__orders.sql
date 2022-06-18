{{ config (
    materialized = 'view'
    ) }}

with orders_source as (
    select o.*
        , oi.product_id
        , oi.order_quantity
    from {{ ref('base_greenery__orders') }} o 
    left join {{ ref('base_greenery__order_items') }} oi on o.order_id = oi.order_id
)
select * from orders_source