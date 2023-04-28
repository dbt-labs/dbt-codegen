{% macro get_tables_in_schema(schema_name, database_name=target.database, table_pattern='%', exclude='') %}
    
    {% set tables=dbt_utils.get_relations_by_pattern(
        schema_pattern=schema_name,
        database=database_name,
        table_pattern=table_pattern,
        exclude=exclude
    ) %}

    {% set table_list= tables | map(attribute='identifier') %}

    {{ return(table_list | sort) }}

{% endmacro %}


---
{% macro generate_source(schema_name, database_name=target.database, generate_columns=False, include_descriptions=False, include_data_types=True, table_pattern='%', exclude='', name=schema_name, table_names=None) %}

{% set sources_yaml=[] %}
{% do sources_yaml.append('version: 2') %}
{% do sources_yaml.append('') %}
{% do sources_yaml.append('sources:') %}
{% do sources_yaml.append('  - name: ' ~ name | lower) %}

{% if include_descriptions %}
    {% do sources_yaml.append('    description: ""' ) %}
{% endif %}

{% if database_name != target.database %}
{% do sources_yaml.append('    database: ' ~ database_name | lower) %}
{% endif %}

{% if schema_name != name %}
{% do sources_yaml.append('    schema: ' ~ schema_name | lower) %}
{% endif %}

{% do sources_yaml.append('    tables:') %}

{% if table_names is none %}
{% set tables=codegen.get_tables_in_schema(schema_name, database_name, table_pattern, exclude) %}
{% else %}
{% set tables = table_names %}
{% endif %}

{% for table in tables %}
    {% do sources_yaml.append('      - name: ' ~ table | lower ) %}
    {% if include_descriptions %}
        {% do sources_yaml.append('        description: ""' ) %}
    {% endif %}
    {% if generate_columns %}
    {% do sources_yaml.append('        columns:') %}

        {% set table_relation=api.Relation.create(
            database=database_name,
            schema=schema_name,
            identifier=table
        ) %}

        {% set columns=adapter.get_columns_in_relation(table_relation) %}

        {% for column in columns %}
            {% do sources_yaml.append('          - name: ' ~ column.name | lower ) %}
            {% if include_data_types %}
                {% set version = (dbt_version.split('.')[0] ~ '.' ~  dbt_version.split('.')[1]) | float %}
                {% if version < 1.5 %}
                    {% set formatted = format_column(column) %}
                {% else %}
                    {% set formatted = adapter.dispatch('format_column', 'dbt')(column) %}
                {% endif %}
                {% do model_yaml.append('        data_type: ' ~ formatted['data_type'] | lower) %}
            {% endif %}
            {% if include_descriptions %}
                {% do sources_yaml.append('            description: ""' ) %}
            {% endif %}
        {% endfor %}
            {% do sources_yaml.append('') %}

    {% endif %}

{% endfor %}

{% if execute %}

    {% set joined = sources_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}
