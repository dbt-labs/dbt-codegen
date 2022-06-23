
{% set raw_schema = generate_schema_name('raw_data') %}

-- test default args
{% set actual_source_yaml = codegen.generate_source(raw_schema, table_pattern='data__%', exclude='data__a_%') %}

{% set expected_source_yaml %}
version: 2

sources:
  - name: {{ raw_schema | trim | lower}}
    tables:
      - name: data__b_relation
      - name: data__campaign_analytics
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
