{% set actual_model_yaml = codegen.generate_model_yaml(
    model_name='codegen_integration_tests__data_source_table'
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: model_yaml
    tables:
      - name: codegen_integration_tests__data_source_table
        description: ""
        columns:
          - name: col_a
            description: ""
          - name: col_b
            description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
