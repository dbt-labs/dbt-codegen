# [beta] dbt-codegen

Macros that generate dbt code, and log it to the command line.

# Macros
## generate_source ([source](macros/generate_source.sql))
This macro generates lightweight YAML for a [Source](https://docs.getdbt.com/docs/using-sources),
which you can then paste into a schema file.
### Usage:
1. Use the macro (in dbt Develop, in a scratch file, or in a run operation) like
  so:
```
{{ codegen.generate_source('raw_jaffle_shop') }}
```
2. The YAML for the source will be logged to the command line
```txt
version: 2

sources:
  - name: raw_jaffle_shop
    tables:
      - name: customers
      - name: orders
      - name: payments
```
3. Paste the output in to a schema file, and refactor as required.


## generate_base_model ([source](macros/generate_base_model.sql))
This macro generates the SQL for a base model, which you can then paste into a
model.

### Usage:
1. Create a source for the table you wish to create a base model on top of.
2. Use the macro (in dbt Develop, or in a scratch file), and compile your code
```
{{
  codegen.generate_base_model(
    source_name='raw_jaffle_shop',
    table_name='customers'
  )
}}
```
3. The SQL for a base model will be logged to the command line
```txt
with source as (

    select * from {{ source('raw_jaffle_shop', 'customers')}}

),

renamed as (

    select
        id,
        first_name,
        last_name,
        email,
        _elt_updated_at

    from source

)

select * from renamed
```
4. Paste the output in to a model, and refactor as required.
