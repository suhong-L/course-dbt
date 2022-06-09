{{config(
    materialized='view'
    )}}

with order_id_source as (
    
    select * from {{ source('greenery', 'order_items') }}
    
)
,
renamed as (
    select
    --primary KEY
    order_id,
    --foreign KEY
    product_id,
    --info
    quantity as order_quantity
from order_id_source
)
select * from renamed


