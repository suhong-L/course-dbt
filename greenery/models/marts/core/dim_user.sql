{{
  config(
    materialized='table'
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
        u.user_updated_at_utc,
        up.has_active_promo_code
    FROM {{ ref('stg_greenery__users') }} u
    left join {{ ref('int_user_promos_agg') }} up on u.user_id = up.user_id
    left join {{ ref('stg_greenery__addresses') }} a on u.address_id = a.address_id
)
select * from user_dimension

-- from this table, you can get the basic information and the geographic profile of the customers.
