{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['Model_Mixed_Case']
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: Model_Mixed_Case
    description: ""
    columns:
      - name: col_a
        data_type: {{ integer_type_value() }}
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
