{% macro generate_model_yml( table_name ) %}

{% set model_yaml=[] %}

{% do model_yaml.append('version: 2') %}
{% do model_yaml.append('') %}
{% do model_yaml.append('models:') %}
{% do model_yaml.append('  - name: ' ~ table_name | lower) %}
{% do model_yaml.append('    description: ' ~ 'table description here') %}
{% do model_yaml.append('    columns:') %}

{% set table_relation=api.Relation.create(
    database=target.database,
    schema=target.schema,
    identifier=table_name
) %}

{% set columns = adapter.get_columns_in_relation(table_relation) %}

{% for column in columns %}
    {% do model_yaml.append('      - name: ' ~ column.name | lower ) %}
    {% do model_yaml.append('        description: ' ~ column.name | lower | replace('_',' ')) %}
    {% do model_yaml.append('') %}
{% endfor %}

{% if execute %}

    {% set joined = model_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
