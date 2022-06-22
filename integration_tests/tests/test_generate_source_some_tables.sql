{% set raw_schema = generate_schema_name('raw_data') %}

-- test all args
{% set actual_source_yaml = codegen.generate_source(
    schema_name=raw_schema,
    database_name=target.database,
    table_names=['data__a_relation'],
    generate_columns=True,
    include_descriptions=True
) %}


{% set expected_source_yaml %}
version: 2

sources:
  - name: {{ raw_schema | trim }}
    description: ""
    tables:
      - name: data__a_relation
        description: ""
        columns:
          - name: col_a
            description: ""
          - name: col_b
            description: ""

{% endset %}

{{ assert_equal (actual_source_yaml | trim, expected_source_yaml | trim) }}
