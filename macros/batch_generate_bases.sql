{% macro batch_generate_bases(source_name, database_name, leading_commas=False, case_sensitive_cols=False, materialized=None, select_star=False) %}
{%- set sources = graph.sources.values() -%}
{%- set existing_node_list = (
    sources |
    selectattr('source_name', "equalto", source_name | lower) |
    selectattr('database', "equalto", database_name | lower) |
    list) 
-%}

{%- for node in existing_node_list -%}
base_{{database_name}}__{{source_name}}_{{node.name}}.sql

{{ codegen.generate_base_model(
    'javascript', 
    node.name, 
    leading_commas, 
    case_sensitive_cols, 
    materialized, 
    select_star) 
}}
{% endfor %}

{% endmacro %}