{% set actual_model_yaml = codegen.generate_unit_test_template(
    model_name='model_from_source',
  )
%}

-- depends_on: {{ ref('model_from_source') }}

{% set expected_model_yaml %}
unit_tests:
  - name: unit_test_model_from_source
    model: model_from_source

    given:
      - input: source("codegen_integration_tests__data_source_schema", "codegen_integration_tests__data_source_table")
        rows:
          - my_integer_col: 
            my_bool_col: 

    expect:
      rows:
        - my_integer_col: 
          my_bool_col:

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
