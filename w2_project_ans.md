# Week 2 Project Answers

## Part 1 Models

### Q1: What is our user repeat rate?
    Repeat Rate = Users who purchased 2 or more times / users who purchased
  - **answer: 79.84%**
  - **query for Q1:**
   ```
    with repeat_rate_source as (
        select user_id
               ,sum(distinct case when order_number >= 2 then 1 else 0 end) as users_purchased_2_or_more
        from dbt_suhong_l.fact_user_order
        group by 1
    )
    select (sum(users_purchased_2_or_more)/count(distinct user_id)) as repeat_rate  from repeat_rate_source;
   ```

### Q2: What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question?
- **answer:
```
do not have enough experience on marketing analysis. base on my understanding,  indicators of a user who will likely purchase/or not purchase again:
1. repeat purchase rate (PRP, or repeat rate in Q1), having a high RPR indicates that you are providing a lot of value to your customers when compared to the price of your products
2. Purchase Frequency: total_orders_made per unique customers during the certain time frame, such as 1 year. it shows the average number of times a customer makes a purchase within a set time frame. it can be used as a benchmark for influencing how often those customers come back to make another purchase.
3. avg Time Between Purchases: total_time/total_orders_made
if I have more data, I will want to add the feedback/comments that the customer made for their purchase, customer's demographic information etc. 
based on these features, we can do the sentiment Analysis on the comment from the user (if we have their feedback on the products or shopping experience), the more positive of the comment they gave, the more likely they will purchase again, vice versa, they will more likely not to purchase again.we can also draw the customers' profile and do behavior analysis to improve our marketing engagement strategies, such as the retention email or customized email 
 
```

### Q3: More stakeholders are coming to us for data, which is great! But we need to get some more models created before we can help. Create a marts folder, so we can organize our models, with the following subfolders for business units: Core | Marketing | Product
DONE, please check the greenery/models/marts in the git repo

### Q4: Within each marts folder, create intermediate models and dimension/fact models. Explain the marts models you added. Why did you organize the models in the way you did?
```
Here is my marts layers and models:
marts: 
    - core    ------------------------------ get the fact and dimension models in the high level
        - intermediate  
            - core_intermediate.yml
            - int_order_delivery_agg.sql
            - int_order_product_agg.sql
            - int_user_promos_agg.sql
        dim_products.sql  ------------------ a table contains information of about what the products is 
        dim_user.sql  ---------------------- a table contains information of user (or customers)
        fact_orders.sql  ------------------- a table will be unique on the order_id level, and contain all the "facts" about an order 
    - marketing   -------------------------- get the fact/dimension based on marketing analysis/kpi requirement
        - intermediate
            - marketing_intermediate.yml
            - int_user_order_agg.sql
        fact_user_orders.sql  -------------- a table will be unique on the user level, and contains all the "facts" about orders per user
    - product    --------------------------- get the fact/dimension based on product level
        - intermediate
            - product_intermediate.yml
            - int_session_events_agg.sql
        fact_page_views.sql ---------------- a table will be unique on the session level, and contains all the "facts" about the session
    
``` 

### Q5. Use the dbt docs to visualize your model DAGs to ensure the model layers make sense
image.png

## Part 2 Tests

### What assumptions are you making about each model? (i.e. why are you adding each test?)
assumption: 
unique test: assume the value in the datafield expecially the id is unique, no duplicate value
not_null: suppose the date field expecially the id is not null value
accepted_values: assume the data field only contains the listed value
relationships: validates that all of the records in a child table have a corresponding record in a parent table
non_negative: assume the data field only contains value >= 0. such as price, quantity, time_length
freshness warn_after:assume the acceptable amount of time between the most recent record, and now is less than 24 hour, if over, then warn
freshness error_after: assume the acceptable amount of time between the most recent record, and now is less than 48 hour, if over, then error
Singular test - delivered_time_not_earlier_than_order_time.sql: test if the delivered_time is later than the order_time by common sense.

### Did you find any "bad" data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?
yes, when the freshness error after is set up at 48 hours, it reports error, cause our data source data is out of the date. To fix this error, I just comment out the freshness error after test, cause in our case, I cannot change the data source. 

### Apply these changes to your github repo
DONE. please check the git repo

### Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.
I have added tests in each layer and also add the store_failure config to some test to make sure we can easily get alert, capture the bad data and do investigation. 