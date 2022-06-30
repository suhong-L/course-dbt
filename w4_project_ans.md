# Week 4 Project Answers

## Part 1. dbt Snapshots 
### Q: Run dbt snapshot again and see how the data has changed for those two orders

the changes for those two orders are as follows:

there will be two records for each of those two orders
the dbt_valid_to of the one with preparing order_status will no longer be null (means it is an outdated record)
instead,  dbt_valid_to of the one with shipped order status will be null, which means it is the up-to-date record. 
specifically please check the result by the following query:

```
select * 
from dbt_suhong_l.orders_snapshot
where  order_id in ('05202733-0e17-4726-97c2-0520c024ab85', '914b8929-e04a-40f8-86ee-357f2be3a2a2')
order by order_id

```
## Part 2. Modeling challenge
### Q. Please create any additional dbt models needed to help answer these questions from our product team, and put your answers in a README in your repo.
Product funnel is defined with 3 levels for our dataset:
```
Sessions with any event of type page_view / add_to_cart / checkout
Sessions with any event of type add_to_cart / checkout
Sessions with any event of type checkout
```
assume the customers will follow the process as page_view -> add_to_cart -> checkout in this example. people won't go to checkout directly after singing into the website. 

**answers:**
 | funnel_level_name | sessions_count |rate_percentage|
 | :--- | :---: | :---: |
 |sessions_with_page_view | 578 | 100.0 |
 |sessions_with_add_to_cart | 467 | 80.8 |
 |sessions_with_checkout | 361 | 62.5 |

 **query for the above ans:**

 ```
    select * from dbt_suhong_l.product_funnel
 
 ```

### Q. Use an exposure on your product analytics model to represent that this is being used in downstream BI tools.
please check the exposures.yml in greenery/marts/product


## Part 3: Reflection questions 

### 3A. dbt next steps for you 
Reflecting on your learning in this class...

#### if your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization?
There are many values of using dbt. firstly, dbt is an open source and sql based. It enables the analysts/engineers/data science to transform data in the warehouse by just simply using the select statement to generate tables or views. secondly, it works with version control, so we can keep tracking every changes of the project and make the team work more efficient. Thirdly, the team can easily share their business logic by using dbt. in addition, dbt can show the dependency of the models which makes the debug easily, Besides, dbt is easy to add docs and test to ensure the data is readable and reliable. 

#### if your organization is using dbt, what are 1-2 things you might do differently / recommend to your organization based on learning from this course?

First I might recommend my organization to set up the critiria for the naming , model layer, doc, test for using the dbt. This is important, cause it makes the whole team using the dbt in the consistent way.

set up the rules and training the team to use version control.

figure out our final business need before start on any dbt project. this is critical for the models and layers design.

Exploring the existing popular packages and try to use them to simplify the process.

#### if you are thinking about moving to analytics engineering, what skills have you picked that give you the most confidence in pursuing this next step?

From this course, I am already clear what is dbt and the whole process to use dbt. 
how to set up a dbt project; 
how to build the staging sources table from cloud databases or other platforms; 
how to design the models layers; 
why and how to doc and test the models;
how to use the jinja and macro and even the existing package to simplify the models;
what is hooks and operation, how to use them to streamline things;
how to snapshot the tables and the ways to snapshot;
what is exposure and when and how to use exposure;
know the basic of dbt project deployment;
know the main artifacts and the importance of using dbt artifacts to track project performance
and also the solid knowledge of using sql
I believe all of these give me the most confidence in pursuing the next step to analytics engineering.  

### 3B. Setting up for production / scheduled dbt run of your project 
#### what steps would you have?
set up the hooks and operation, build the production pineline, set up the schedule for dbt seed,  dbt snapshot, dbt run, dbt test, generate dbt docs and how to deal with the metadata 
set up the alerts of the failed test or run error to the relevant team memembers and stakeholders by using the metadata.

#### Which orchestration tool(s) would you be interested in using?
I am not familiar with any orchestration tool(s) so far. Based on this course's introduction, I will go for Dagster cause it looks easy to navigate and build the pineline. 

#### What schedule would you run your project on?
 for different business, the dbt run and snapshot schedule will definitely different. for this project,  e-platform data, I will prefer to set up daily run and snapshot schedule at night, cause the data change quickly and run it at night won't influence the business analysis and reporting.

#### Which metadata would you be interested in using? How/why would you use the specific metadata? 
These are the metadata I will be interested in using and tracking:
1. run_results.json -> because it contains metadata about the various dbt objects that were run, tested, seed, snapshot, compile etc. it can be used to check and track of the performent of the models and tests, etc. over time. base on the result, we can easily find out which models or test need to be improved. 

2. manifest.json -> reason for it is this metadata provides informatin about the dbt project's configuration. it can be used to track how many models have decriptions, which macros are being used across the project etc, it is useful to understand how objects are interconnected. 