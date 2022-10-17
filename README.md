# dbt-codegen

Macros that generate dbt code, and log it to the command line.

# Contents
* [generate_source](#generate_source-source)
* [generate_base_model](#generate_base_model-source)
* [create_base_models](#create_base_models-source)
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
* `generate_columns` (optional, default=False): Whether you want to add the
column names to your source definition.
* `include_descriptions` (optional, default=False): Whether you want to add 
description placeholders to your source definition.

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
$ dbt run-operation generate_source --args '{"schema_name": "jaffle_shop", "database_name": "raw"}'
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

## create_base_models ([source](macros/create_base_models.sql))
This macro generates a series of terminal commands (appended with the `&&` to allow for subsequent execution) that execute the [base_model_creation](#base_model_creation-source) bash script. This bash script will write the output of the [generate_base_model](#generate_base_model-source) macro into a new model file in your local dbt project.
>**Note**: This macro is not compatible with the dbt Cloud IDE.

### Arguments:
* `source_name` (required): The source you wish to generate base model SQL for.
* `tables` (required): A list of all tables you want to generate the base models for.

### Usage:
1. Create a source for the table you wish to create a base model on top of.
2. Copy the macro into a statement tab into your local IDE, and run your code

```sql
dbt run-operation codegen.create_base_models --args '{source_name: my-source, tables: ["this-table","that-table"]}'
```
## base_model_creation ([source](bash_scripts/base_model_creation.sh))
This bash script when executed from your local IDE will create model files in your dbt project instance that contain the outputs of the [generate_base_model](macros/generate_base_model.sql) macro.
>**Note**: This macro is not compatible with the dbt Cloud IDE.

### Arguments:
* `source_name` (required): The source you wish to generate base model SQL for.
* `tables` (required): A list of all tables you want to generate the base models for.

### Usage:
1. Create a source for the table you wish to create a base model on top of.
2. Copy the macro into a statement tab into your local IDE, and run your code

```bash
source dbt_packages/codegen/bash_scripts/base_model_creation.sh "source_name" ["this-table","that-table"]
```

## generate_model_yaml ([source](macros/generate_model_yaml.sql))
This macro generates the YAML for a model, which you can then paste into a
schema.yml file.

### Arguments:
* `model_name` (required): The model you wish to generate YAML for.

### Usage:
1. Create a model.
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_model_yaml(
    model_name='customers'
) }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_model_yaml --args '{"model_name": "customers"}'
```

3. The YAML for a base model will be logged to the command line

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
