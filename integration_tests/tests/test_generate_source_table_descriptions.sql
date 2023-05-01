
{% set raw_schema = generate_schema_name('raw_data') %}

-- test default args
{% set actual_source_yaml = codegen.generate_source(raw_schema, include_descriptions=True) %}

{% set expected_source_yaml %}
version: 2

sources:
  - name: {{ raw_schema | trim | lower }}
    description: ""
    tables:
      - name: data__a_relation
        description: ""
      - name: data__b_relation
        description: ""
      - name: data__campaign_analytics
        description: ""
{% endset %}


{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
