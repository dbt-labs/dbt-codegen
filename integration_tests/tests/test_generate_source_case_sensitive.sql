
{% set raw_schema = generate_schema_name('Raw_Data_Case_Sensitive') %}

-- test default args
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
  - name: {{ raw_schema | lower }}
    database: {{ target.database }}
    schema: {{ raw_schema }}
    tables:
      - name: {% if target.type == "snowflake" %}DATA__CASE_SENSITIVE{% else %}data__Case_Sensitive{% endif %}
        columns:
          - name: Col_A
            data_type: {{ integer_type_value() }}
          - name: Col_B
            data_type: {{ text_type_value() }}
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
