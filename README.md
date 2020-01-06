# dbt-codegen

Macros that generate dbt code, and log it to the command line.

# Macros
## generate_source ([source](macros/generate_source.sql))
This macro generates lightweight YAML for a [Source](https://docs.getdbt.com/docs/using-sources),
which you can then paste into a schema file.

### Arguments
* `schema_name` (required): The schema name that contains your source data
* `database_name` (optional, default=target.database): The database that your
source data is in.
* `generate_columns` (optional, default=False): Whether you want to add the
column names to your source definition.

### Usage:
1. Use the macro (in dbt Develop, in a scratch file, or in a run operation) like
  so:
```
{{ codegen.generate_source('raw_jaffle_shop') }}
```
Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```
$ dbt run-operation generate_source --args 'schema_name: raw_jaffle_shop'
```
or
```
# for multiple arguments, use the dict syntax
$ dbt run-operation generate_source --args '{"schema_name": "raw_jaffle_shop", "database_name": "raw"}'
```
2. The YAML for the source will be logged to the command line
```txt
version: 2

sources:
  - name: raw_jaffle_shop
    database: raw
    tables:
      - name: customers
      - name: orders
      - name: payments
```
3. Paste the output in to a schema `.yml` file, and refactor as required.

## generate_base_model ([source](macros/generate_base_model.sql))
This macro generates the SQL for a base model, which you can then paste into a
model.

### Arguments:
* `source_name` (required): The source you wish to generate base model SQL for.
* `table_name` (required): The source table you wish to generate base model SQL for.


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
Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```
$ dbt run-operation generate_base_model --args '{"source_name": "raw_jaffle_shop", "table_name": "customers"}'
```

3. The SQL for a base model will be logged to the command line
```txt
with source as (

    select * from {{ source('raw_jaffle_shop', 'customers') }}

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

## generate_model_yml ([source](macros/generate_model_yml.sql))
This macro generates the yml for any model your run in your target profile, which you can then paste into a yml file.

### Arguments:
* `model_name` (required): The model you wish to generate the yml file for.


### Usage:
1. Run the model in your target.
2. Use the macro (in dbt Develop, or in a scratch file), and compile your code
```
{{ codegen.generate_model_yml('my_model') }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```
$ dbt run-operation generate_model_yml --args 'model_name: my_model'
```
3. The YAML for the model will be logged to the command line
```txt
version: 2

models:
  - name: my_model
    description: table description here
    columns:
      - name: col_1
        description: col 1

      - name: col_2
        description: col 2

```
4. Paste the output in to a schema `.yml` file, and refactor as required.
