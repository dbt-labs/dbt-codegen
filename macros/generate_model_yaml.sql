{% macro generate_column_yaml(column, model_yaml, column_desc_dict, parent_column_name="") %}
    {% if parent_column_name %}
        {% set column_name = parent_column_name ~ "." ~ column.name %}
    {% else %}
        {% set column_name = column.name %}
    {% endif %}

    {% do model_yaml.append('      - name: ' ~ column.name | lower ) %}
    {% do model_yaml.append('        description: "' ~ column_desc_dict.get(column.name | lower,'') ~ '"') %}
    {% do model_yaml.append('') %}
    {% if column.fields|length > 0 %}
        {% for child_column in column.fields %}
            {% set model_yaml = generate_column_yaml(child_column, model_yaml, column_desc_dict, parent_column_name=column_name) %}
        {% endfor %}
    {% endif %}
    {% do return(model_yaml) %}
{% endmacro %}

{% macro generate_model_yaml(model_name, upstream_descriptions=False) %}

{% set model_yaml=[] %}
{% set column_desc_dict =  codegen.build_dict_column_descriptions(model_name) if upstream_descriptions else {} %}

{% do model_yaml.append('version: 2') %}
{% do model_yaml.append('') %}
{% do model_yaml.append('models:') %}
{% do model_yaml.append('  - name: ' ~ model_name | lower) %}
{% do model_yaml.append('    description: ""') %}
{% do model_yaml.append('    columns:') %}

{% set relation=ref(model_name) %}
{%- set columns = adapter.get_columns_in_relation(relation) -%}

{% for column in columns %}
    {% set model_yaml = generate_column_yaml(column, model_yaml, column_desc_dict) %}
{% endfor %}

{% if execute %}

    {% set joined = model_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}