{{ config (
    materialized = 'view'
) }}

with session_event_agg as (
    {%- set event_types = dbt_utils.get_column_values(table = ref('stg_greenery__events'), column='event_type')  -%}
    select session_id
          ,user_id
          ,event_created_at_utc
          {% for event_type in event_types %}
          ,sum(case when event_type = '{{event_type}}' then 1 else 0 end) as {{event_type}}
          {% endfor %}
    from {{ ref('stg_greenery__events') }} e
    group by session_id, user_id, event_created_at_utc
)
,
session_duration as (
    select session_id
          ,count(distinct event_type) as event_type_per_session
          ,min(event_created_at_utc) as first_event_at
          ,max(event_created_at_utc) as last_event_at
    from {{ ref('stg_greenery__events') }} e
    group by session_id
)
,
session_agg_final as (
    select 
          sa.*
          ,sl.event_type_per_session
          ,sl.first_event_at
          ,sl.last_event_at
          ,round(cast (extract (EPOCH from (last_event_at- first_event_at))/60 as numeric), 0) as session_length_min
    from session_event_agg sa
    left join session_duration sl on sa.session_id = sl.session_id
)
select distinct * from session_agg_final



