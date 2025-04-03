{% set actual_model_yaml = codegen.generate_unit_test_template(
    model_name='data__a_relation',
    inline_columns=False
  )
%}

-- depends_on: {{ ref('data__a_relation') }}

{% set expected_model_yaml %}
unit_tests:
  - name: unit_test_data__a_relation
    model: data__a_relation

    given: []

    expect:
      rows:
        - col_a: 
          col_b:

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
