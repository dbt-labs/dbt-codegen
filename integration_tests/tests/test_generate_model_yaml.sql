{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['data__a_relation']
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: data__a_relation
    description: ""
    columns:
      - name: col_a
        data_type: {{ integer_type_value() }}
        description: ""

      - name: col_b
        data_type: {{ text_type_value() }}
        description: ""

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
