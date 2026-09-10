{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['model_from_source_case_sensitive'],
    case_sensitive_cols=True
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: model_from_source_case_sensitive
    description: ""
    columns:
      - name: My_Integer_Col
        data_type: {{ integer_type_value() }}
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
