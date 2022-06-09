{{config(
    materialized='view'
    )}}

with address_source as (
    
    select * from {{ source('greenery', 'addresses') }}
    
)
,
renamed as (
    select
    --primary KEY
    address_id,
    --info
    address,
    zipcode
    state,
    country
from address_source
)
select * from renamed


