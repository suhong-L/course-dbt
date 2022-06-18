{{ config(
    materialized = 'view'
)}}

with delivered_time as (
    select distinct order_id
         , user_id
         , cast(extract (EPOCH from (order_delivered_at_utc - order_created_at_utc))/3600/24 as numeric) as delivery_time_days
    from {{ ref('base_greenery__orders') }} o 
    where order_status =  'delivered'
)
select * from delivered_time