{% macro generate_model_yml( model_name ) %}

{% set model_yaml=[] %}

{% do model_yaml.append('version: 2') %}
{% do model_yaml.append('') %}
{% do model_yaml.append('models:') %}
{% do model_yaml.append('  - name: ' ~ model_name | lower) %}
{% do model_yaml.append('    description: ' ~ 'table description here') %}
{% do model_yaml.append('    columns:') %}

{% set table_relation=ref(model_name) %}

{% do model_yaml.append( ( codegen.generate_columns_yaml(table_relation) | join ('\n')) ) %}

{% if execute %}

    {% set joined = model_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
