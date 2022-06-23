{{ config(
    materialized = 'table'
)}}
with page_view as (
    select  sa.session_id
            ,event_type_per_session
            ,package_shipped
            ,page_view
            ,checkout
            ,add_to_cart
            ,first_event_at
            ,last_event_at
            ,session_length_min
            ,sa.user_id
            ,u.first_name
            ,u.last_name
            ,u.email
            ,(u.user_created_at_utc)::DATE as registered_date
            ,u.address_id
    from {{ ref('int_session_events_agg') }} sa
    left join {{ ref('stg_greenery__users') }} u on u.user_id = sa.user_id
)
select * from page_view order by session_length_min DESC
