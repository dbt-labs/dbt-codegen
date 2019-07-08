{% macro create_source_table() %}

{% set target_schema="test_data_source" %}

{% do adapter.create_schema(target.database, target_schema) %}

{%- set target_relation = api.Relation.create(
    identifier='my_test_table',
    schema=target_schema,
    type='table'
) %}


{% set source_sql %}
select
    1 as my_integer_col,
    true as my_bool_col
{% endset %}

{% do create_table_as(
    temporary=False,
    relation=target_relation,
    sql=source_sql
) %}

{% endmacro %}
