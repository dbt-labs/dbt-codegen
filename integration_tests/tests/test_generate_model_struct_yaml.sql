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


{% set expected_source_yaml %}
version: 2

models:
  - name: model_struct
    description: ""
    columns:
      - name: analytics
        description: ""

      - name: source
        description: ""

      - name: medium
        description: ""

      - name: source_medium
        description: ""

      - name: col_x
        description: ""

{% endset %}

{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
