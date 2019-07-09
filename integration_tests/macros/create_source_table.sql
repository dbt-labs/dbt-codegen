{% macro create_source_table() %}

{% set target_schema="codegen_integration_tests__data_source_schema" %}

{% do adapter.create_schema(target.database, target_schema) %}

{% set query_sql %}
drop table if exists {{ target_schema }}.codegen_integration_tests__data_source_table;
create table {{ target_schema }}.codegen_integration_tests__data_source_table as (
    select
        1 as my_integer_col,
        true as my_bool_col
)

{% endset %}

{{ run_query(query_sql) }}

{% endmacro %}
