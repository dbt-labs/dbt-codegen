# dbt-code-gen

Macros that generate dbt code, and log it to the command line.

The expected workflow is:
* Use these macros within dbt Develop to generate dbt code
* Paste the generated code into your project, refactoring as required


# Macros
## generate_base_model ([source](macros/generate_base_mode.sql))
This macro generates the SQL for a base model, which you can then paste into a
model.

### Usage:
1. Create a source for the table you wish to create a base model on top of.
2. Use the macro (in dbt Develop, or in a scratch file), and compile your code
```
{{
  code_gen.generate_base_model(
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

# To-do:
* Macros to generate sources for a schema
