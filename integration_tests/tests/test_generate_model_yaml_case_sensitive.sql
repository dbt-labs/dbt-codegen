{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['Case_Sensitive_Model'],
    case_sensitive_models=True,
    case_sensitive_cols=True
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: Case_Sensitive_Model
    description: ""
    columns:
      - name: col_A
        data_type: {{ integer_type_value() }}
        description: ""

      - name: col_B
        data_type: {{ text_type_value() }}
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
