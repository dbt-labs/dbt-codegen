{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['data__a_relation','data__b_relation']
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: data__a_relation
    description: ""
    columns:
      - name: col_a
        description: ""

      - name: col_b
        description: ""

  - name: data__b_relation
    description: ""
    columns:
      - name: col_a
        description: ""

      - name: col_b
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
