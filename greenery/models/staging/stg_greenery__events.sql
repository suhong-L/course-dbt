{{ config(
    materialized = 'view'
    ) }}
    
with event_source as (
    
    select * from {{ source('greenery', 'events') }}
    
)
,
renamed as (
        select
            --primary KEY
            event_id,
            --foreign KEY
            session_id,
            user_id,
            product_id,
            --info
            page_url,
            event_type,
            --snapshot date
            created_at as event_created_at_utc
        from event_source
)
select * from renamed
