# generate _*sources.yml for all tables in a schema.
dbt-generate-source database schema:
    {{dbt}} run-operation codegen.generate_source --args '{"schema_name": "{{schema}}", "database_name": "{{database}}"}'

# generate the model sql for a table defined in your sources yml to speed up renaming step.
dbt-generate-base-model source table:
    @{{dbt}} run-operation codegen.generate_base_model --args '{"source_name": "{{source}}", "table_name": "{{table}}"}'  > generated/stg_{{table}}.sql
    @awk '/with source as \(/{p=1} p' generated/stg_{{table}}.sql > temp && mv temp generated/stg_{{table}}.sql
    @echo "Model {{table}} generated in generated/stg_{{table}}.sql"

# generate model yml with all columns from a model sql file.
generated_default := 'generated'
dbt-generate-model-yaml model_name generated_folder=generated_default:
    @if [ ! -d "{{generated_folder}}" ]; then \
        mkdir -p {{generated_folder}}; \
    fi
    @{{dbt}} run-operation codegen.generate_model_yaml --args '{"model_names": ["{{model_name}}"]}' > /tmp/{{model_name}}.tmpyml
    @awk '/models:/{p=1} p' /tmp/{{model_name}}.tmpyml > /tmp/temp{{model_name}} && mv /tmp/temp{{model_name}} {{generated_folder}}/{{model_name}}.yml
    @echo "Model {{model_name}} generated in {{generated_folder}}/{{model_name}}.yml"

# generate model yml with all columns for all sql files without accompanying yml files.
# optionally accept a parameter for folder to search in
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

# Clean up model references in your sql files by generating CTE aliases for all models referenced in a sql file.
dbt-generate-model-import-ctes model_name generated_folder=generated_default:
    @if [ ! -d "{{generated_folder}}" ]; then \
        mkdir -p {{generated_folder}}; \
    fi
    @{{dbt}} run-operation codegen.generate_model_import_ctes --args '{"model_name": "{{model_name}}"}'> /tmp/{{model_name}}.tmpsql
    @awk '/with .* as \($/{p=1} p' /tmp/{{model_name}}.tmpsql | sed 's/^.*with/with/' > /tmp/temp{{model_name}} && mv /tmp/temp{{model_name}} {{generated_folder}}/{{model_name}}.sql
    @echo "SQL {{model_name}} edited in {{generated_folder}}/{{model_name}}.sql"
