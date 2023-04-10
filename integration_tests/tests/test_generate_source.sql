
{% set raw_schema = generate_schema_name('raw_data') %}

-- test default args
{% set actual_source_yaml = codegen.generate_source(raw_schema) %}

{% set expected_source_yaml %}
version: 2

sources:
  - name: {{ raw_schema | trim | lower }}
    database: analytics
    schema: codegen_integration_tests_snowflake_raw_data
    tables:
      - name: data__a_relation
      - name: data__b_relation
      - name: data__campaign_analytics
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
