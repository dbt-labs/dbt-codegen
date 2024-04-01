
{% set raw_schema = generate_schema_name('Raw_Data_Case_Sensitive') %}

-- test default args
{% set actual_source_yaml = codegen.generate_source(
    schema_name=raw_schema,
    database_name=target.database,
    generate_columns=True,
    name=raw_schema,
    include_database=True,
    include_schema=True
) %}

{% set expected_source_yaml %}
version: 2

sources:
  - name: codegen_integration_tests_postgres_raw_data_case_sensitive
    database: circle_test
    schema: codegen_integration_tests_postgres_Raw_Data_Case_Sensitive
    tables:
      - name: data__Case_Sensitive
        columns:
          - name: Col_A
            data_type: integer
          - name: Col_B
            data_type: text
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
