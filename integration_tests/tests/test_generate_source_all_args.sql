{% set raw_schema = generate_schema_name('raw_data') %}

-- test all args
{% set actual_source_yaml = codegen.generate_source(
    schema_name=raw_schema,
    table_pattern='%',
    exclude='',
    database_name=target.database,
    generate_columns=True,
    include_descriptions=True,
    include_data_types=True,
    name=raw_schema,
    table_names=None,
    include_database=True,
    include_schema=True,
    case_sensitive_databases=False,
    case_sensitive_schemas=False,
    case_sensitive_tables=False,
    case_sensitive_cols=False
) %}


{% set expected_source_yaml %}

version: 2

sources:
  - name: {{ raw_schema | trim | lower }}
    description: ""
    database: {{ target.database | trim | lower }}
    schema: {{ raw_schema | trim | lower }}
    tables:
      - name: data__a_relation
        description: ""
        columns:
          - name: col_a
            data_type: {{ integer_type_value() }}
            description: ""
          - name: col_b
            data_type: {{ text_type_value() }}
            description: ""

      - name: data__a_relation_case_sensitive_columns
        description: ""
        columns:
          - name: col_a
            data_type: {{ integer_type_value() }}
            description: ""
          - name: col_b
            data_type: {{ text_type_value() }}
            description: ""

      - name: data__b_relation
        description: ""
        columns:
          - name: col_a
            data_type: {{ integer_type_value() }}
            description: ""
          - name: col_b
            data_type: {{ text_type_value() }}
            description: ""

      - name: data__campaign_analytics
        description: ""
        columns:
          - name: source
            data_type: {{ text_type_value() }}
            description: ""
          - name: medium
            data_type: {{ text_type_value() }}
            description: ""
          - name: source_medium
            data_type: {{ text_type_value() }}
            description: ""
          - name: analytics
            data_type: {{ integer_type_value() }}
            description: ""
          - name: col_x
            data_type: {{ text_type_value() }}
            description: ""

{% endset %}

{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
