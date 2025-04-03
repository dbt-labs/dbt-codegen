{% set actual_model_yaml = codegen.generate_unit_test_template(
    model_name='child_model',
    inline_columns=False
  )
%}

-- depends_on: {{ ref('model_data_a') }}
-- depends_on: {{ ref('child_model') }}

{% set expected_model_yaml %}
unit_tests:
  - name: unit_test_child_model
    model: child_model

    given:
      - input: ref("model_data_a")
        rows:
          - col_a: 
            col_b: 

    expect:
      rows:
        - col_a: 
          col_b: 

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
