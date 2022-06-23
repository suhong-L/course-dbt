{%- macro get_ratio_percentage(col_1, col_2) -%}

    cast((cast({{ col_1 }} as numeric)/{{ col_2 }})*100 as numeric(6,2))

{%- endmacro -%}