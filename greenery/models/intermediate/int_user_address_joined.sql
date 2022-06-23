{{
  config(
    materialized='view'
  )
}}

with user_dimension as (
    SELECT
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.phone_number,
        u.address_id,
        a.address,
        a.zipcode,
        a.state,
        a.country,
        u.user_created_at_utc,
        (u.user_created_at_utc)::Date AS registered_date,
        u.user_updated_at_utc
    FROM {{ ref('stg_greenery__users') }} u
    left join {{ ref('stg_greenery__addresses') }} a on u.address_id = a.address_id
)
select * from user_dimension