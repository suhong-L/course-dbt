{{ config(
    materialized = 'view'
    ) }}

with user_source as (
    
    select * from {{ source('greenery', 'users') }}
    
)
,
renamed as (
    select
        --primary KEY
        user_id,
        --foreign KEY
        address_id,
        --info
        first_name,
        last_name,
        email,
        phone_number,
        --snapshot date
        created_at as user_created_at_utc,
        updated_at as user_updated_at_utc
    from user_source
)
select * from renamed
