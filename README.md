# dbt-codegen

Macros that generate dbt code, and log it to the command line.

# Contents
* [generate_source](#generate_source-source)
* [generate_base_model](#generate_base_model-source)
* [generate_model_yaml](#generate_model_yaml-source)

# Installation instructions
New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).
1. Include this package in your `packages.yml` file — check [here](https://hub.getdbt.com/dbt-labs/codegen/latest/) for the latest version number.
2. Run `dbt deps` to install the package.

# Macros
## generate_source ([source](macros/generate_source.sql))
This macro generates lightweight YAML for a [Source](https://docs.getdbt.com/docs/using-sources),
which you can then paste into a schema file.

### Arguments
* `schema_name` (required): The schema name that contains your source data
* `database_name` (optional, default=target.database): The database that your
source data is in.
* `table_names` (optional, default=none): A list of tables that you want to generate the source definitions for.
* `generate_columns` (optional, default=False): Whether you want to add the
column names to your source definition.
* `include_descriptions` (optional, default=False): Whether you want to add 
description placeholders to your source definition.
* `table_pattern` (optional, default='%'): A table prefix / postfix that you 
want to subselect from all available tables within a given schema.
* `exclude` (optional, default=''): A string you want to exclude from the selection criteria
* `name` (optional, default=schema_name): The name of your source

### Usage:
1. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

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
$ dbt run-operation generate_source --args '{"schema_name": "jaffle_shop", "database_name": "raw", "table_names":["table_1", "table_2"]}'
```

2. The YAML for the source will be logged to the command line

```
version: 2

sources:
  - name: raw_jaffle_shop
    database: raw
    tables:
      - name: customers
        description: ""
      - name: orders
        description: ""
      - name: payments
        description: ""
```

3. Paste the output in to a schema `.yml` file, and refactor as required.

## generate_base_model ([source](macros/generate_base_model.sql))
This macro generates the SQL for a base model, which you can then paste into a
model.

### Arguments:
* `source_name` (required): The source you wish to generate base model SQL for.
* `table_name` (required): The source table you wish to generate base model SQL for.
* `leading_commas` (optional, default=False): Whether you want your commas to be leading (vs trailing).
* `case_sensitive_cols ` (optional, default=False): Whether your source table has case sensitive column names. If true, keeps the case of the column names from the source.


### Usage:
1. Create a source for the table you wish to create a base model on top of.
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_base_model(
    source_name='raw_jaffle_shop',
    table_name='customers'
) }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_base_model --args '{"source_name": "raw_jaffle_shop", "table_name": "customers"}'
```

3. The SQL for a base model will be logged to the command line

```
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
This macro generates the YAML for a list of model(s), which you can then paste into a
schema.yml file.

### Arguments:
* `model_names` (required): The model(s) you wish to generate YAML for.
* `upstream_descriptions` (optional, default=False): Whether you want to include descriptions for identical column names from upstream models.

### Usage:
1. Create a model.
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_model_yaml(
    model_names=['customers']
) }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_model_yaml --args '{"model_names": ["customers"]}'
```

3. The YAML for a base model(s) will be logged to the command line

```
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
