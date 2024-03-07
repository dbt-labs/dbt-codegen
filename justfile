# Running without a recipe will list all available recipes.
default:
  @just --list --list-prefix=" ✴︎ "

venv_name := ".venv"

venv:
  [ -d {{venv_name}} ] || python3 -m venv {{venv_name}}

dev-setup adapter: venv
  ./{{venv_name}}/bin/python3 -m pip install --upgrade pip
  ./{{venv_name}}/bin/python3 -m pip install --pre dbt-core dbt-{{adapter}}

# Generate _sources.yml for all tables in a schema.
dbt-generate-source database schema:
    @dbt run-operation codegen.generate_source --args '{"schema_name": "{{schema}}", "database_name": "{{database}}"}'

alias gso := dbt-generate-source

# Generate the model sql for a table defined in your sources yml
dbt-generate-base-model source table:
    @dbt run-operation codegen.generate_base_model --args '{"source_name": "{{source}}", "table_name": "{{table}}"}'  > generated/stg_{{table}}.sql
    @awk '/with source as \(/{p=1} p' generated/stg_{{table}}.sql > temp && mv temp generated/stg_{{table}}.sql
    @echo "Model {{table}} generated in generated/stg_{{table}}.sql"

alias gbase := dbt-generate-base-model

# Generate model yml with all columns from a model sql file.
generated_default := 'generated'
dbt-generate-model-yaml model_name generated_folder=generated_default:
    @if [ ! -d "{{generated_folder}}" ]; then \
        mkdir -p {{generated_folder}}; \
    fi
    @dbt run-operation codegen.generate_model_yaml --args '{"model_names": ["{{model_name}}"]}' > /tmp/{{model_name}}.tmpyml
    @awk '/models:/{p=1} p' /tmp/{{model_name}}.tmpyml > /tmp/temp{{model_name}} && mv /tmp/temp{{model_name}} {{generated_folder}}/{{model_name}}.yml
    @echo "Model {{model_name}} generated in {{generated_folder}}/{{model_name}}.yml"

alias gmy := dbt-generate-model-yaml

# generate model yml with all columns for all sql files without accompanying yml files.
# Optionally accepts a parameter for folder to search in.
default_folder := 'models'
dbt-generate-missing-yaml folder=default_folder:
    @for sql_file in $(find {{folder}} -type f -name '*.sql'); do \
        yml_file=${sql_file%.sql}.yml; \
        if [ ! -f $yml_file ]; then \
            model_name=${sql_file##*/}; \
            model_name=${model_name%.sql}; \
            folder_name=$(dirname ${sql_file}); \
            just dbt-generate-model-yaml $model_name $folder_name; \
        fi; \
    done

alias gmiss := dbt-generate-missing-yaml

# Clean up model references in your sql files by generating 'import 'CTEs for models referenced.
dbt-generate-model-import-ctes model_name generated_folder=generated_default:
    @if [ ! -d "{{generated_folder}}" ]; then \
        mkdir -p {{generated_folder}}; \
    fi
    @dbt run-operation codegen.generate_model_import_ctes --args '{"model_name": "{{model_name}}"}' > /tmp/{{model_name}}.tmpsql
    @awk '/with .* as \($/{p=1} p' /tmp/{{model_name}}.tmpsql | sed 's/^.*with/with/' > /tmp/temp{{model_name}} && mv /tmp/temp{{model_name}} {{generated_folder}}/{{model_name}}.sql
    @echo "SQL {{model_name}} updated in {{generated_folder}}/{{model_name}}.sql"

alias gmic := dbt-generate-model-import-ctes
