{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['child_model'],
    upstream_descriptions=True,
    include_data_types=False
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: child_model
    description: ""
    columns:
      - name: col_a
        description: "description column \"a\""

      - name: col_b
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
