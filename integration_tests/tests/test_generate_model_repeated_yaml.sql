{% set raw_schema = generate_schema_name('raw_data') %}

{% set actual_source_yaml = codegen.generate_model_yaml(
    model_names=['model_repeated']
  )
%}

{% if target.type == "bigquery" %}

{% set expected_source_yaml %}
version: 2

models:
  - name: model_repeated
    description: ""
    columns:
      - name: repeated_int
        data_type: array<int64>
        description: ""

      - name: repeated_struct
        data_type: array<struct<`nested_int_field` int64, `nested_repeated_struct` array<struct<`string_field` string>>>>
        description: ""

      - name: repeated_struct.nested_int_field
        data_type: int64
        description: ""

      - name: repeated_struct.nested_repeated_struct
        data_type: array<struct<`string_field` string>>
        description: ""

      - name: repeated_struct.nested_repeated_struct.string_field
        data_type: string
        description: ""

{% endset %}

{% else %}

{% set expected_source_yaml %}
version: 2

models:
  - name: model_repeated
    description: ""
    columns:
      - name: int_field
        data_type: {{ integer_type_value() }}
        description: ""

{% endset %}

{% endif %}

{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
