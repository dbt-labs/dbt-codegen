{% set raw_schema = generate_schema_name('raw_data') %}

-- test all args
{% set actual_source_yaml = codegen.generate_source(
    database_name=target.database,
    schema_name='codegen_integration_tests__data_source_schema',
    table_names=['codegen_integration_tests__data_source_table_nested_array'],
    generate_columns=True,
    include_descriptions=True
) %}

{% set actual_source_yaml = codegen.generate_model_yaml(
    model_names=['model_struct']
  )
%}

{% if target.type == "bigquery" %}

{% set expected_source_yaml %}
version: 2

models:
  - name: model_struct
    description: ""
    columns:
      - name: analytics
        data_type: int64
        description: ""

      - name: analytics.source
        data_type: string
        description: ""

      - name: analytics.medium
        data_type: string
        description: ""

      - name: analytics.source_medium
        data_type: string
        description: ""

      - name: col_x
        data_type: string
        description: ""

{% endset %}

{% else %}

{% set expected_source_yaml %}
version: 2

models:
  - name: model_struct
    description: ""
    columns:
      - name: analytics
        data_type: integer
        description: ""

      - name: source
        data_type: text
        description: ""

      - name: medium
        data_type: text
        description: ""

      - name: source_medium
        data_type: text
        description: ""

      - name: col_x
        data_type: text
        description: ""

{% endset %}

{% endif %}

{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
