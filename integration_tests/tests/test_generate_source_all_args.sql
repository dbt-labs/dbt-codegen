{% set raw_schema = generate_schema_name('raw_data') %}

-- test all args
{% set actual_source_yaml = codegen.generate_source(
    schema_name=raw_schema,
    table_pattern='%',
    exclude='',
    database_name=target.database,
    generate_columns=True,
    include_descriptions=True,
    name=raw_schema
) %}


{% set expected_source_yaml %}

version: 2

sources:
  - name: {{ raw_schema | trim | lower }}
    description: ""
    tables:
      - name: data__a_relation
        description: ""
        columns:
          - name: col_a
            description: ""
          - name: col_b
            description: ""

      - name: data__b_relation
        description: ""
        columns:
          - name: col_a
            description: ""
          - name: col_b
            description: ""

      - name: data__campaign_analytics
        description: ""
        columns:
          - name: source
            description: ""
          - name: medium
            description: ""
          - name: source_medium
            description: ""
          - name: analytics
            description: ""
          - name: col_x
            description: ""

{% endset %}

{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
