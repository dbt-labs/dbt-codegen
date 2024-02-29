{% macro create_base_models(source_name, tables) %}
    {{ return(adapter.dispatch('create_base_models', 'codegen')(source_name, tables)) }}
{% endmacro %}

{% macro default__create_base_models(source_name, tables) %}

{% set source_name = ""~ source_name ~"" %}

{% set zsh_command_models = "source dbt_packages/codegen/bash_scripts/base_model_creation.sh """~ source_name ~""" " %}

{%- set models_array = [] -%}

{% for t in tables %}
    {% set help_command = zsh_command_models + t %}
    {{ models_array.append(help_command) }}
{% endfor %}

{{ log("Run these commands in your shell to generate the models:\n" ~ models_array|join(' && \n'), info=True) }}

{% endmacro %}
