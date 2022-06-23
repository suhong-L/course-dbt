{{ config(
    materialized = 'view'
    ) }}

with order_source as (
    
    select * from {{ source('greenery', 'orders') }}
    
)
,
renamed as (
    select
        --primary KEY
        order_id,
        --foreign KEY
        user_id,
        promo_id,
        address_id,
        --info
        order_cost,
        shipping_cost,
        order_total as order_total_cost,
        tracking_id,
        shipping_service as shipping_service_company,
        estimated_delivery_at,
        status as order_status,
        --snapshot date
        created_at as order_created_at_utc,
        delivered_at as order_delivered_at_utc
    from order_source
)
select * from renamed


