{# Test with case_sensitive_data_types=False (default behavior) #}
{% set actual_model_yaml_lowercase = codegen.generate_model_yaml(
    model_names=['model_from_source'],
    case_sensitive_data_types=False
  )
%}

{% set expected_model_yaml_lowercase %}
version: 2

models:
  - name: model_from_source
    description: ""
    columns:
      - name: my_integer_col
        data_type: {{ integer_type_value() | lower }}
        description: ""

      - name: my_bool_col
        data_type: {{ bool_type_value() | lower }}
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml_lowercase | trim, expected_model_yaml_lowercase | trim) }}