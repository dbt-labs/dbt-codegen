{# Test with case_sensitive_data_types=True #}
{% set actual_model_yaml_uppercase = codegen.generate_model_yaml(
    model_names=['model_from_source'],
    case_sensitive_data_types=True
  )
%}

{% set expected_model_yaml_uppercase %}
version: 2

models:
  - name: model_from_source
    description: ""
    columns:
      - name: my_integer_col
        data_type: {{ integer_type_value(case_sensitive=True) }}
        description: ""

      - name: my_bool_col
        data_type: {{ bool_type_value(case_sensitive=True) }}
        description: ""

{% endset %}


{{ assert_equal (actual_model_yaml_uppercase | trim, expected_model_yaml_uppercase | trim) }} 