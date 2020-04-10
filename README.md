# dbt-codegen

Macros that generate dbt code, and log it to the command line.

# Contents
* [generate_source](#generate_source-source)
* [generate_base_model](#generate_base_model-source)

# Installation instructions
New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).
1. Include this package in your `packages.yml` file — check [here](https://hub.getdbt.com/fishtown-analytics/codegen/latest/) for the latest version number.
2. Run `dbt deps` to install the package.

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




## generate_model_yaml ([source](macros/generate_model_yaml.sql))
This macro generates the YAML for a model, which you can then paste into a
schema.yml file.

### Arguments:
* `model_name` (required): The model you wish to generate YAML for.

### Usage:
1. Create a model.
2. Use the macro (in dbt Develop, or in a scratch file), and compile your code
```
{{
  codegen.generate_model_yaml(
    model_name='customers'
  )
}}
```
Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):
```
$ dbt run-operation generate_model_yaml --args '{"model_name": "customers"}'
```

3. The YAML for a base model will be logged to the command line
```txt
version: 2

models:
  - name: customers
    columns:
      - name: customer_id
        description: ""
      - name: customer_name
        description: ""
```
4. Paste the output in to a schema.yml file, and refactor as required.