{{config(
    materialized='view'
    )}}

with promo_source as (
    
    select * from {{ source('greenery', 'promos') }}
    
)
,
renamed as (
    select
        --primary KEY
        promo_id,
        --info
        discount as promo_discount,
        status as promo_status
    from promo_source
)
select * from renamed
