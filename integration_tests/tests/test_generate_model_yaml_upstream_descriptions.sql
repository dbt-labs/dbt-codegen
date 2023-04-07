{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['child_model'],
    upstream_descriptions=True
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: child_model
    description: ""
    columns:
      - name: col_a
        data_type: integer
        description: "description column a"

      - name: col_b
        data_type: text
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
