{% set actual_model_yaml = codegen.generate_unit_test_template(
    model_name='model_incremental',
  )
%}

-- depends_on: {{ ref('model_incremental') }}

{% set expected_model_yaml %}
unit_tests:
  - name: unit_test_model_incremental
    model: model_incremental

    overrides:
      macros:
        is_incremental: true

    given:
      - input: this
        rows:
          - id: 

    expect:
      rows:
        - id:

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
