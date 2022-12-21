# dbt-codegen

Macros that generate dbt code, and log it to the command line.

# Contents
- [dbt-codegen](#dbt-codegen)
- [Contents](#contents)
- [Installation instructions](#installation-instructions)
- [Macros](#macros)
  - [generate_source (source)](#generate_source-source)
    - [Arguments](#arguments)
    - [Usage:](#usage)
  - [generate_base_model (source)](#generate_base_model-source)
    - [Arguments:](#arguments-1)
    - [Usage:](#usage-1)
  - [create_base_models (source)](#create_base_models-source)
    - [Arguments:](#arguments-2)
    - [Usage:](#usage-2)
  - [base_model_creation (source)](#base_model_creation-source)
    - [Arguments:](#arguments-3)
    - [Usage:](#usage-3)
  - [generate_model_yaml (source)](#generate_model_yaml-source)
    - [Arguments:](#arguments-4)
    - [Usage:](#usage-4)
  - [generate_model_import_ctes (source)](#generate_model_import_ctes-source)
    - [Arguments:](#arguments-5)
    - [Usage:](#usage-5)

# Installation instructions
New to dbt packages? Read more about them [here](https://docs.getdbt.com/docs/building-a-dbt-project/package-management/).
1. Include this package in your `packages.yml` file — check [here](https://hub.getdbt.com/dbt-labs/codegen/latest/) for the latest version number:
```yml
packages:
  - package: dbt-labs/codegen
    version: X.X.X ## update to latest version here
```
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
* `include_data_types` (optional, default=False): Whether you want to add data
types to your source columns definitions.
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

Including data types:

```
$ dbt run-operation generate_source --args '{"schema_name": "jaffle_shop", "generate_columns": "true", "include_data_types": "true"}'
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
* `materialized` (optional, default=None): Set materialization style (e.g. table, view, incremental) inside of the model's `config` block. If not set, materialization style will be controlled by `dbt_project.yml`


### Usage:
1. Create a source for the table you wish to create a base model on top of.
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_base_model(
    source_name='raw_jaffle_shop',
    table_name='customers',
    materialized='table'
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

## generate_model_import_ctes ([source](macros/generate_model_import_ctes.sql))
This macro generates the SQL for a given model with all references pulled up into import CTEs, which you can then paste back into the model.

### Arguments:
* `model_name` (required): The model you wish to generate SQL with import CTEs for.
* `leading_commas` (optional, default = false): Whether you want your commas to be leading (vs trailing).

### Usage:
1. Create a model with your original SQL query
2. Copy the macro into a statement tab in the dbt Cloud IDE, or into an analysis file, and compile your code

```
{{ codegen.generate_model_import_ctes(
    model_name = 'my_dbt_model'
) }}
```

Alternatively, call the macro as an [operation](https://docs.getdbt.com/docs/using-operations):

```
$ dbt run-operation generate_model_import_ctes --args '{"model_name": "my_dbt_model"}'
```

3. The new SQL - with all references pulled up into import CTEs - will be logged to the command line

```
with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select * from {{ ref('stg_orders') }}

),

payments as (

    select * from {{ ref('stg_payments') }}

),

customer_orders as (

    select
        customer_id,
        min(order_date) as first_order,
        max(order_date) as most_recent_order,
        count(order_id) as number_of_orders
    from orders
    group by customer_id

),

customer_payments as (

    select
        orders.customer_id,
        sum(amount) as total_amount
    from payments
    left join orders on
         payments.order_id = orders.order_id
    group by orders.customer_id

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order,
        customer_orders.most_recent_order,
        customer_orders.number_of_orders,
        customer_payments.total_amount as customer_lifetime_value
    from customers
    left join customer_orders
        on customers.customer_id = customer_orders.customer_id
    left join customer_payments
        on  customers.customer_id = customer_payments.customer_id

)

select * from final
```

4. Replace the contents of the model's current SQL file with the compiled or logged code