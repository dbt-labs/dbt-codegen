{% if target.type == 'redshift' %}
    select 'ok' limit 0
{% else %}
{% set raw_schema = generate_schema_name('Raw_Data_Case_Sensitive') %}

{% set actual_source_yaml = codegen.generate_source(
    schema_name=raw_schema,
    database_name=target.database,
    generate_columns=True,
    name=raw_schema,
    include_database=True,
    include_schema=True,
    case_sensitive_databases=True,
    case_sensitive_schemas=True,
    case_sensitive_tables=True,
    case_sensitive_cols=True
) %}

{% set expected_source_yaml %}
version: 2

sources:
  - name: {{ raw_schema | trim | lower }}
    database: circle_test
    schema: {{ raw_schema | trim }}
    tables:
      - name: data__Case_Sensitive
        columns:
          - name: Col_A
            data_type: integer
          - name: Col_B
            data_type: text
{% endset %}

{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
{%- endif -%}
