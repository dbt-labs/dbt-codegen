
{% set raw_schema = generate_schema_name('raw_data') %}

-- test default args
{% set actual_source_yaml = codegen.generate_source(raw_schema, table_pattern='data__%') %}

{% set expected_source_yaml %}
version: 2

sources:
  - name: {{ raw_schema | trim }}
    tables:
      - name: data__a_relation
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
