{% set raw_schema=generate_schema_name('raw_data') %}

-- test default args
{{ codegen.generate_source(raw_schema) }}

-- test all args
{{ codegen.generate_source(
    schema_name=raw_schema,
    database_name=target.database,
    generate_columns=True
) }}
