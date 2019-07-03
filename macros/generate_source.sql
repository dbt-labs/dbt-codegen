{% macro get_tables_in_schema(schema_name) %}
    {% set tables=dbt_utils.get_tables_by_prefix(
            schema=schema_name,
            prefix=''
        )
    %}

    {% set table_list=[] %}

    {% for table in tables %}
        {% do table_list.append(table.identifier) %}
    {% endfor %}
    {{ return(table_list | sort) }}
{% endmacro %}


---
{% macro generate_source(schema_name, database_name=target.database, generate_columns=False) %}

{% set sources_yaml=[] %}

{% do sources_yaml.append('version: 2') %}
{% do sources_yaml.append('') %}
{% do sources_yaml.append('sources:') %}
{% do sources_yaml.append('  - name: ' ~ schema_name) %}
{% do sources_yaml.append('    tables:') %}

{% set tables=codegen.get_tables_in_schema(schema_name) %}

{% for table in tables %}
    {% do sources_yaml.append('      - name: ' ~ table) %}

    {% if generate_columns %}
    {% do sources_yaml.append('        columns:') %}

        {% set table_relation=api.Relation.create(
            database=database_name,
            schema=schema_name,
            identifier=table
        ) %}

        {% set columns=adapter.get_columns_in_relation(table_relation) %}

        {% for column in columns %}
            {% do sources_yaml.append('          - name: ' ~ column.name) %}
        {% endfor %}
            {% do sources_yaml.append('') %}

    {% endif %}

{% endfor %}

{% if execute %}

    {{ log(sources_yaml | join ('\n'), info=True) }}

{% endif %}

{% endmacro %}
