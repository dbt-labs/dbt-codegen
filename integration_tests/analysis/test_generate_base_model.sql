{% set raw_schema=generate_schema_name('raw_data') %}

{{
  codegen.generate_base_model(
    source_name=raw_schema,
    table_name='data__a_relation'
  )
}}
