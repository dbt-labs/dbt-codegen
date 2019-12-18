{% set actual_model_yml = codegen.generate_model_yml(
    table_name='data__a_relation'
  )
%}

{% set expected_model_yml %}
version: 2

models:
  - name: data__a_relation
    description: table description here
    columns:
      - name: col_a
        description: col a

      - name: col_b
        description: col b


{% endset %}

{{ assert_equal (actual_model_yml | trim, expected_model_yml | trim) }}