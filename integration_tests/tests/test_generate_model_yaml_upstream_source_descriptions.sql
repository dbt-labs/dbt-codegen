{% set actual_model_yaml = codegen.generate_model_yaml(
    model_names=['model_from_source'],
    upstream_descriptions=True,
    include_data_types=False
  )
%}

{% set expected_model_yaml %}
version: 2

models:
  - name: model_from_source
    description: ""
    columns:
      - name: my_integer_col
        description: "My Integer Column"

      - name: my_bool_col
        description: "My Boolean Column"

{% endset %}

{{ assert_equal (actual_model_yaml | trim, expected_model_yaml | trim) }}
