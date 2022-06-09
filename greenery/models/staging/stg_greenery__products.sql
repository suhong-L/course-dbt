{{config(
    materialized='view'
    )}}

with product_source as (
    
    select * from {{ source('greenery', 'products') }}
    
)
,
renamed as (
    select
        --primary KEY
        product_id,
        --info
        name as product_name,
        price as product_price,
        inventory as product_inventory
    from product_source
)
select * from renamed
