{% macro format_column(column) -%}
  {{ return(adapter.dispatch('format_column', 'codegen')(column)) }}
{%- endmacro %}

{# Vendored from: https://github.com/dbt-labs/dbt-adapters/blob/c7b12aee533184bad391a657d1753539d1dd496a/dbt/include/global_project/macros/relations/column/columns_spec_ddl.sql#L85-L89 #}
{% macro default__format_column(column) -%}
  {% set data_type = column.dtype %}
  {% set formatted = column.column.lower() ~ " " ~ data_type %}
  {{ return({'name': column.name, 'data_type': data_type, 'formatted': formatted}) }}
{%- endmacro -%}

{# Vendored from: https://github.com/dbt-labs/dbt-bigquery/blob/4d255b2f854d21d5d8871bdaa8d7ab47e7e863a3/dbt/include/bigquery/macros/utils/get_columns_spec_ddl.sql#L1-L5 #}
{% macro bigquery__format_column(column) -%}
  {% set data_type = column.data_type %}
  {% set formatted = column.column.lower() ~ " " ~ data_type %}
  {{ return({'name': column.name, 'data_type': data_type, 'formatted': formatted}) }}
{%- endmacro -%}