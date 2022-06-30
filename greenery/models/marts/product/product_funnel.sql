{{ config(
    materialized = 'table'
)}}

with product_funnel_sessions as (
    select 
        event_type 
        , count( distinct session_id) as session_counts

        from {{ ref('stg_greenery__events') }} a 
        where event_type != 'package_shipped'
        group by event_type
        
)
,
sessions_with_page_view as (
    select count(distinct case when page_view > 0 then session_id else Null end) as session_with_page_view
         , min(first_event_at) as first_event_at
         , max(last_event_at) as last_event_at
    from {{ ref('int_session_events_agg') }}
)
,
product_funnel_final as (
    select case event_type when 'page_view' then 1
                       when 'add_to_cart' then 2
                       when 'checkout' then 3 end as funnel_level_rank
          ,case event_type when 'page_view' then 'sessions_with_page_view'
                       when 'add_to_cart' then 'sessions_with_add_to_cart'
                       when 'checkout' then 'sessions_with_checkout' end as funnel_level_name
          , session_counts
          , {{ get_ratio_percentage('session_counts', 'swpv.session_with_page_view') }} as rate_percentage
          , first_event_at
          , last_event_at
from product_funnel_sessions pfs
cross join sessions_with_page_view swpv
)
select * from product_funnel_final order by funnel_level_rank 


 
