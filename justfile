##############################################################################
#                                                      88  88
#    88                            ,d                  88  88            ,d 
#                                  88                  88  88            88
#    88  88       88  ,adPPYba,  MM88MMM       ,adPPYb,88  88,dPPYba,  MM88MMM
#    88  88       88  I8[    ""    88         a8"    `Y88  88P'    "8a   88
#    88  88       88   `"Y8ba,     88         8b       88  88       d8   88
#    88  "8a,   ,a88  aa    ]8I    88,        "8a,   ,d88  88b,   ,a8"   88,
#    88   `"YbbdP'Y8  `"YbbdP"'    "Y888       `"8bbdP"Y8  8Y"Ybbd8"'    "Y888
#   ,88
# 888P"
##############################################################################
# Justfile created by @wjhrdy
#
# Contributors:
# - @gwenwindflower
##############################################################################
# Configuration for the just task runner
# You set the two variables below.
#
# `venv_name` is the name of the virtual environment to create. Defaults to '.venv'.
# If you choose a different name make sure to add it to your .gitignore file.
#
# `pm` is the package manager to use. This can be one of ['pip', 'poetry', 'uv'].
#
# Details on each can be found at:
# - pip: Python's default package manager https://pip.pypa.io/en/stable/
# - poetry: A fully integrated Python development tool https://python-poetry.org/
# - uv: An ultra-fast pip alternative with the same API as pip https://astral.sh/uv
#
# We default to pip as it is the most common package manager for Python, but this
# Justfile was originally created with poetry in mind, as it lets you run commands
# in a virtual environment without having to activate it first with `poetry run`.
#
# `just` runs each command in a fresh shell, so commands that rely on installed
# dependencies like `dbt` need the virtual environment activated first, which is
# why `poetry run` is so handy. For `pip` and `uv`, we activate the virtual 
# environment before running these commands in the same shell. You can see
# the logic and recipes for this at the end of the file in the 'Developer recipes'.
#
# Start of user configuration:
##############################################################################
venv_name := '.venv'
pm := "pip"
##############################################################################
# End of user configuration.
##############################################################################

##############################################################################
# User recipes.
# These are the codegen commands you can run with `just`.
# You can add more recipes in this section for your workflow.
# If you want to share a recipe you create we welcome PRs to the 
# `dbt-codgen` repo! -> https://github.com/dbt-labs/dbt-codegen
#
# Check out the just documentation here for more on writing your own recipes:
# https://just.systems/
##############################################################################

# List all recipes.
default:
  @just --list --list-prefix=" ✴︎ "

# Generate _sources.yml for all tables in a schema.
dbt-generate-source database schema:
    @{{dbt}} run-operation codegen.generate_source --args '{"schema_name": "{{schema}}", "database_name": "{{database}}"}'

alias gso := dbt-generate-source

# Generate a sql model for a table defined in your sources YAML.
dbt-generate-base-model source table:
    @{{dbt}} run-operation codegen.generate_base_model --args '{"source_name": "{{source}}", "table_name": "{{table}}"}'  > generated/stg_{{table}}.sql
    @awk '/with source as \(/{p=1} p' generated/stg_{{table}}.sql > temp && mv temp generated/stg_{{table}}.sql
    @echo "Model {{table}} generated in generated/stg_{{table}}.sql"

alias gbase := dbt-generate-base-model

# Generate YAML config with all columns from a SQL model file.
generated_default := 'generated'
dbt-generate-model-yaml model_name generated_folder=generated_default:
    @if [ ! -d "{{generated_folder}}" ]; then \
        mkdir -p {{generated_folder}}; \
    fi
    @{{dbt}} run-operation codegen.generate_model_yaml --args '{"model_names": ["{{model_name}}"]}' > /tmp/{{model_name}}.tmpyml
    @awk '/models:/{p=1} p' /tmp/{{model_name}}.tmpyml > /tmp/temp{{model_name}} && mv /tmp/temp{{model_name}} {{generated_folder}}/{{model_name}}.yml
    @echo "Model {{model_name}} generated in {{generated_folder}}/{{model_name}}.yml"

alias gmy := dbt-generate-model-yaml

# Generate YAML config for any unconfigured SQL models.
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

# Clean up model references in your SQL models by generating 'import CTEs' for all `{{ ref}}`s.
dbt-generate-model-import-ctes model_name generated_folder=generated_default:
    @if [ ! -d "{{generated_folder}}" ]; then \
        mkdir -p {{generated_folder}}; \
    fi
    @{{dbt}} run-operation codegen.generate_model_import_ctes --args '{"model_name": "{{model_name}}"}' > /tmp/{{model_name}}.tmpsql
    @awk '/with .* as \($/{p=1} p' /tmp/{{model_name}}.tmpsql | sed 's/^.*with/with/' > /tmp/temp{{model_name}} && mv /tmp/temp{{model_name}} {{generated_folder}}/{{model_name}}.sql
    @echo "SQL {{model_name}} updated in {{generated_folder}}/{{model_name}}.sql"

alias gmic := dbt-generate-model-import-ctes

##############################################################################
# End of user recipes.
##############################################################################

##############################################################################
# Developer recipes for testing and debugging the justfile.
##############################################################################

# Verify the package manager logic is working.
test-dbt-command:
  @echo {{dbt}}

##############################################################################
# End of developer recipes.
##############################################################################

##############################################################################
# Package manager recipes.
# You should not edit this unless you're adding a new package manager.
##############################################################################
va := if pm == "pip" {
    "source " + venv_name / "bin/activate &&"
  }  else if pm == "uv" {
    "source " + venv_name / "bin/activate &&"
  } else if pm == "poetry" {
    "poetry run "
  } else {
    error("Invalid package manager")
  }

dbt := va + " dbt"

create_venv_label := "Creating virtual environment with " + pm + "..."
create_venv := if pm == "pip" {
    "python3 -m venv " + venv_name
  }  else if pm == "uv" {
    "uv venv " + venv_name
  } else if pm == "poetry" {
    "poetry shell"
  } else {
    error("Invalid package manager")
  }

deps_label := "Installing dependencies with " + pm + "..."
deps := if pm == "pip" {
    "pip install -r requirements.txt"
  }  else if pm == "uv" {
    "uv pip install -r requirements.txt"
  } else if pm == "poetry" {
    "poetry install"
  } else {
    error("Invalid package manager")
  }

venv:
  @echo {{create_venv_label}}
  @[[ -d {{venv_name}} ]] || {{create_venv}}

deps: venv
  @echo {{deps_label}}
  @{{deps}}

######################################################################
# End of package manager recipes.
######################################################################
