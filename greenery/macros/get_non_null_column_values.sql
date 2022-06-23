{%- macro get_non_null_column_values(model_name,column_name) -%}

{%- set non_null_column_query -%}
select distinct
{{column_name}}
from {{ ref(model_name) }}
where {{column_name}} is not null
order by 1
{%- endset -%}

{%- set results = run_query(non_null_column_query) -%}

{{ log(results, info=True) }}

{{ return([]) }}

{%- endmacro -%}