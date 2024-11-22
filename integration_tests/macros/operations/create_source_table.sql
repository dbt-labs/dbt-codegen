{% macro create_source_table() %}

{% set target_schema=api.Relation.create(
    database=target.database,
    schema="codegen_integration_tests__data_source_schema"
) %}


{% do adapter.create_schema(target_schema) %}

{% set drop_table_sql %}
drop table if exists {{ target_schema }}.codegen_integration_tests__data_source_table {% if target.type == "redshift" %}cascade{% endif %}
{% endset %}

{{ run_query(drop_table_sql) }}


{% set create_table_sql %}
create table {{ target_schema }}.codegen_integration_tests__data_source_table as (
    select
        1 as my_integer_col,
        true as my_bool_col
)
{% endset %}

{{ run_query(create_table_sql) }}

{% set drop_table_sql_case_sensitive %}
drop table if exists {{ target_schema }}.codegen_integration_tests__data_source_table_case_sensitive {% if target.type == "redshift" %}cascade{% endif %}
{% endset %}

{{ run_query(drop_table_sql_case_sensitive) }}

{% set create_table_sql_case_sensitive %}
create table {{ target_schema }}.codegen_integration_tests__data_source_table_case_sensitive as (
    select
        1 as {{ adapter.quote("My_Integer_Col") }},
        true as {{ adapter.quote("My_Bool_Col") }}
)
{% endset %}

{{ run_query(create_table_sql_case_sensitive) }}

{% endmacro %}
