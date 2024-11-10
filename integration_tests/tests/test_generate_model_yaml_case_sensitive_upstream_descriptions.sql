{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['Case_Sensitive_Child_Model'],
    upstream_descriptions=True,
    include_data_types=False,
    case_sensitive_models=True,
    case_sensitive_cols=True
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: Case_Sensitive_Child_Model
    description: ""
    columns:
      - name: col_A
        description: "description column \"a\""

      - name: col_B
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
