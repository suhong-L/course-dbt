# Week 3 Project Answers

## Part 1 

### Q1-1: What is our overall conversion rate? 
    assume one session will only made by one user.

   **overall conversion_rate: 62.46%**
  - **query for it:**
   ```
    -- overall conversion_rate
    with session_agg as(
    select count(distinct session_id) as total_sessions
        , sum(checkout) as purchase_sessions
        from dbt_suhong_l.page_views 
    )
    select ((purchase_sessions::numeric /total_sessions)* 100) ::numeric(6,2) as overall_conversion_rate_percentage from session_agg;

   ```

### Q1-2: What is our conversion rate by product?
a session with the purchase event of a product in this case is defined by a session that a product is added to cart, followed by the same session with an checkout event. 

  **conversion_rate_by_product**: (the values in conversion_rate_percentage below are in % format, for example 60.94 means 60.94%) 
 | product_name | conversion_rate_percentage |
 | :--- | :---: |
 | String of pearls | 60.94 |
 | Arrow Head | 55.56 |
 | Cactus | 54.55 |
 | ZZ Plant | 53.97 |
 | Bamboo | 53.73 |
 | Rubber Plant | 51.85 |
 | Monstera | 51.02 |
 | Calathea Makoyana | 50.94 |
 | Fiddle Leaf Fig | 50.00 |
 | Majesty Palm | 49.25 |
 | Aloe Vera | 49.23 |
 | Devil's Ivy | 48.89 |
 | Philodendron | 48.39 |
 | Jade Plant | 47.83 |
 | Spider Plant | 47.46 |
 | Pilea Peperomioides | 47.46 |
 | Dragon Tree | 46.77 |
 | Money Tree | 46.43 |
 | Orchid | 45.33 |
 | Bird of Paradise | 45.00 |
 | Ficus |	42.65 |
 | Birds Nest Fern |	42.31 |
 | Pink Anthurium | 41.89 |
 | Boston Fern |	41.27 |
 | Alocasia Polly |	41.18 |
 | Peace Lily |	40.91 |
 | Ponytail Palm |	40.00 |
 | Snake Plant |	39.73 |
 | Angel Wings Begonia |	39.34 |
 | Pothos | 34.43 |

- **query:**
```
-- conversion_rate by products
    select product_name
         , conversion_rate_percentage
    from dbt_suhong_l.products
    order by conversion_rate_percentage desc;

```
## Part 2
### Create a macro to simplify part of a model(s)
please check my macros in my greenry dbt project. I have created a generic test macro non_negative, a grant role macro for hooks and operation
get_ratio_percentage macro to get the conversion rate etc

## Part 3
### Add a post hook to your project to apply grants to the role “reporting”. Create reporting role first by running CREATE ROLE reporting in your database instance.
DONE. please check my dbt_project.yml and also the macro grant_select in the greenery

```
SELECT grantee
     , privilege_type
FROM information_schema.role_table_grants
WHERE table_name= 'products'
-- returns result as grantee: reporting, privilege_type: select
```

## Part 4
### Install a package (i.e. dbt-utils, dbt-expectations) and apply one or more of the macros to your project
DONE. have install package as follows:
```
packages:
  - package: dbt-labs/dbt_utils
    version: 0.8.5
  - package: calogica/dbt_expectations
    version: 0.5.6
```
use dbt_utils dbt_utils.get_column_values and dbt_utils.pivot in the mart models

## PART 5
### Show (using dbt docs and the model DAGs) how you have simplified or improved a DAG using macros and/or dbt packages.
please check the DAG in the submission.