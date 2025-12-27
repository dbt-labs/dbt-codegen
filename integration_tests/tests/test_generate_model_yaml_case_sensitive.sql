{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['Model_from_source_case_sensitive'],
    case_sensitive_models=True,
    case_sensitive_cols=True,
    include_data_types=False
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: Model_from_source_case_sensitive
    description: ""
    columns:
      - name: My_Integer_Col
        description: ""

      - name: My_Bool_Col
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
