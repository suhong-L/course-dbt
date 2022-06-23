{{ config (
    materialized = 'table'
) }}

with user_order_agg as (
    select user_id
            , count(distinct o.order_id) as order_number
            , sum(order_total_cost) as total_cost
            , sum(opa.total_product_ordered) as total_product_ordered
            , min(order_created_at_utc) as first_order_time
            , max(order_created_at_utc) as last_order_time
            , round((extract (EPOCH from (max(order_created_at_utc)- min(order_created_at_utc)))/3600)::numeric,1) as order_length_hour            
    from {{ ref('stg_greenery__orders') }} o
    left join {{ ref('int_order_product_agg') }} opa on o.order_id = opa.order_id
    group by  user_id
)
,
user_promos_agg as (
    select  o.user_id
          , count(o.promo_id) as active_code_count
          , sum(promo_discount) as total_abs_discount
          , case when count(o.promo_id) > 0 then 'Y' else 'N' end as has_active_promo_code
    from {{ ref('stg_greenery__orders') }}o
    join {{ ref('stg_greenery__promos') }}p on o.promo_id = p.promo_id
    where promo_status = 'active'
    group by user_id
) 
,
avg_delivery_time as (
        select user_id
            ,count(distinct order_id) as delivered_orders
            ,sum(delivery_time_days) as delivery_time_days
            ,sum(delivery_time_days)/count(distinct order_id) as avg_delivery_days
        from {{ ref('int_order_delivery_agg') }}
        group by user_id
)
,
user_order_final as (
    select uoa.user_id
         , u.first_name
         , u.last_name
         , u.email
         , u.state
         , u.country
         , uoa.order_number
         , round(cast( uoa.total_cost as numeric),2) as total_cost
         , total_product_ordered
         --, case when upa.active_code_count is null then 0 else upa.active_code_count end as active_code_count
         , coalesce(active_code_count,0) as active_code_count
         , coalesce(upa.total_abs_discount,0) as total_abs_discount
         , coalesce(upa.has_active_promo_code,'N') as has_active_promo_code
         , round(cast(uoa.total_cost - coalesce(upa.total_abs_discount,0) as numeric),2) as total_cost_after_discount
         , round(cast((uoa.total_cost - coalesce(upa.total_abs_discount,0))/order_number as numeric), 2) as avg_cost_per_order
         , first_order_time
         , last_order_time
         , order_length_hour 
         , round(cast(order_length_hour/order_number as numeric),2) as avg_hour_between_orders
         , (CURRENT_DATE - (last_order_time::date)) as days_since_last_purchase
        --  , round(cast(avg_delivery_days as numeric),2) as avg_delivery_days
    from user_order_agg uoa 
    -- left join avg_delivery_time adt on adt.user_id = uoa.user_id
    left join {{ ref('int_user_address_joined') }} u on u.user_id = uoa.user_id
    left join user_promos_agg upa on upa.user_id = uoa.user_id   
)
select * from user_order_final
order by order_number DESC