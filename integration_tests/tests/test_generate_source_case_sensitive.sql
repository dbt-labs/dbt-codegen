{% if target.type == 'redshift' %}
    {% set raw_schema = generate_schema_name('raw_data_case_sensitive') %}
{% else %}
    {% set raw_schema = generate_schema_name('Raw_Data_Case_Sensitive') %}
{% endif %}

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

{% if target.type == 'redshift' -%}
sources:
  - name: {{ raw_schema | trim | lower }}
    database: {{ target.database | trim | lower }}
    schema: {{ raw_schema | trim | lower }}
    tables:
      - name: data__case_sensitive
        columns:
          - name: col_a
            data_type: integer
          - name: col_b
            data_type: text
{%- else -%}
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
{%- endif -%}
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
