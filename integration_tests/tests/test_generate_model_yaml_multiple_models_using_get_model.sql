{% set actual_model_yaml_prefix = codegen.generate_model_yaml(
    model_names = codegen.get_models(prefix='child_')
  )
%}

{% set expected_model_yaml_prefix %}
version: 2

models:
  - name: child_model
    description: ""
    columns:
      - name: col_a
        description: ""

      - name: col_b
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml_prefix | trim, expected_model_yaml_prefix | trim) }}
