## Week 1 Project Answers

### Q1: How many users do we have?
  - **answer: 130**
  - **query for Q1:**
   ```
    select count(distinct user_id) as total_users 
    from dbt_suhong_l.stg_greenery__users;
   ```

### Q2: On average, how many orders do we receive per hour?

assume the on-line shopping platform runs 24/7. The time for order being created is continous, which means even when a specific hour between first order and last order does not have any order, we will count the order during that hour as 0 to get the avg order per hour. 

  - **answer: 7.52 orders or 8 orders if round to integer**
  - **query for Q1:** 
```
    with unique_orders_within_Total_order_time as (
        select count (distinct order_id) as total_unique_order_count
            , min(order_created_at) as first_order_created_time
            , max(order_created_at) as last_order_created_time
            , ROUND((extract (EPOCH from (max(order_created_at)-min(order_created_at)))/3600)::Numeric, 0) as total_order_hours
        from dbt_suhong_l.stg_greenery__orders
    )
    select round(total_unique_order_count/total_order_hours,2) as avg_order_per_hour
    from unique_orders_within_Total_order_time
```

### Q3: On average, how long does an order take from being placed to being delivered?
  - **answer: 3.89 days or 4 days if round to integer**
  - **query for Q3:**
```
    with unique_delivered_order as (
                    select distinct order_id
                        , (extract (EPOCH from (order_delivered_at - order_created_at))/3600) as delivery_time_in_hour  
                    from dbt_suhong_l.stg_greenery__orders
                    where order_delivered_at is not null -- only care about the delivered order
    )
    select round(cast(avg(delivery_time_in_hour)/24 as Numeric),2) from unique_delivered_order
```

### Q4: How many users have only made one purchase? Two purchases? Three+ purchases?

Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.

 - **answer:** 
 ```
    one purchanse: 25 users; 
    Two purchases: 28 users; 
    Three+ purchases: 71 users.
 ```
 - **query for Q4:**
 ```
    with  user_purchase_number as (
            select user_id
                  , case count(distinct order_id) when 1 then '1 purchanse'
                                                  when 2 then '2 purchases'
                    else '3+ purchases' end as purchase_number
            from dbt_suhong_l.stg_greenery__orders
            where user_id is not null -- ignore the case when user_id is null
            group by  user_id
    )
    select purchase_number
            , count(distinct user_id) as number_of_user
        from user_purchase_number
        group by purchase_number;
 ```   

### Q5: On average, how many unique sessions do we have per hour?

assume the on-line shopping platform runs 24/7. the time for event happen is continous, which means even when a specific hour between the first event and the last event does not have any session, we will count the session during that hour as 0 to get the average sessions per hour. 

 - **answer: 16.61 sessions or 17 sessions if round to integer**
 - **query for Q5:**
 ```
    with hourly_unique_session as (
             select date_trunc('hour',created_at) as event_hour
                  , count(distinct session_id) as unique_session_count
                  , min(created_at) as first_event_time
                  , max(created_at) as last_event_time
            from dbt_suhong_l.stg_greenery__events
            group by date_trunc('hour',created_at)
    )
    select round(sum(unique_session_count) / round((extract (EPOCH from (max(last_event_time)- min(first_event_time)))/3600)::Numeric,0),2) as avg_sessions_per_hour
    from hourly_unique_session;
```

