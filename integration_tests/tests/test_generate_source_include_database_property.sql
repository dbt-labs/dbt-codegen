
{% set raw_schema = generate_schema_name('raw_data') %}

{% set actual_source_yaml = codegen.generate_source(raw_schema, include_database=True) %}

{% set expected_source_yaml %}
version: 2

sources:
  - name: {{ raw_schema | trim | lower }}
    database: analytics
    tables:
      - name: data__a_relation
      - name: data__b_relation
      - name: data__campaign_analytics
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
