{% snapshot orders_snapshot %}

{{
    config(
      target_database=target.database,
      target_schema=target.schema,
      unique_key='order_id',

      strategy='check',
      check_cols=['order_status'],
    )
}}

select * from {{ ref('stg_greenery__orders') }}

{% endsnapshot %}