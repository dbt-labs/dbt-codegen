
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
    schema: codegen_integration_tests_postgres_raw_data_case_sensitive
    tables:
      - name: data__case_sensitive
        columns:
          - name: col_a
            data_type: integer
          - name: col_b
            data_type: text
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
