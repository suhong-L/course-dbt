{{ config(
    materialized = 'table'
)}}

with fact_order as (
    select distinct o.* 
          ,oda.delivery_time_days
          ,opa.product_count
          ,opa.total_product_ordered
          ,a.state
          ,a.country
    from {{ ref('base_greenery__orders') }} o
    left join {{ ref('int_order_delivery_agg') }} oda on o.order_id = oda.order_id
    left join {{ ref('int_order_product_agg') }} opa on o.order_id = opa.order_id
    left join {{ ref('stg_greenery__addresses')}} a on o.address_id = a.address_id
)
select * from fact_order


