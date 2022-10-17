{% macro create_base_models(source_schema, tables) %}

{% set source_schema = ""~ source_schema ~"" %}

{% set zsh_command_models = "source dbt_packages/codegen/bash_scripts/base_model_creation.sh """~ source_schema ~""" " %}

{%- set models_array = [] -%}

{% for t in tables %}
    {% set help_command = zsh_command_models + t %}
    {{ models_array.append(help_command) }}
{% endfor %}

{{ log(columns_array|join(' && \n') + ' && \n' + models_array|join(' && \n'), info=True) }}

{% endmacro %}
