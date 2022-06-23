{{ config(
    materialized = 'table'
)}}

with order_pivot_order_status as (
    select order_id
          ,{{ dbt_utils.pivot(
              'order_status',
              dbt_utils.get_column_values(ref('stg_greenery__orders'), 'order_status')
             ) }}
    from {{ ref('stg_greenery__orders') }}
    group by order_id
)
,

fact_order as (
    select o.order_id
          ,o.order_cost
          ,o.shipping_cost
          ,o.order_total_cost
          ,coalesce(p.promo_discount,0) as promo_discount
          ,coalesce(p.promo_status, 'N/A') as promo_status
          ,round(cast(o.order_total_cost - coalesce(p.promo_discount,0) as numeric),2) as order_final_cost
          ,o.tracking_id
          ,o.shipping_service_company
          ,opo.preparing
          ,opo.shipped
          ,opo.delivered
          ,o.estimated_delivery_at
          ,o.order_status
          ,o.order_created_at_utc
          ,o.order_delivered_at_utc
          ,oda.delivery_time_days
          ,opa.product_count
          ,opa.total_product_ordered
          ,o.user_id 
          ,u.state
          ,u.country
    from {{ ref('stg_greenery__orders') }} o
    left join order_pivot_order_status opo on opo.order_id = o.order_id
    left join {{ ref('int_order_delivery_agg') }} oda on o.order_id = oda.order_id
    left join {{ ref('int_order_product_agg') }} opa on o.order_id = opa.order_id
    left join {{ ref('stg_greenery__promos') }} p on p.promo_id = o.promo_id and promo_status = 'active'
    left join {{ ref('int_user_address_joined') }} u on u.user_id = o.user_id
)
select * from fact_order


