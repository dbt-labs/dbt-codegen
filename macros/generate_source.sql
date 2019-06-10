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
{% macro generate_source(schema_name) %}

{% set sources_yaml=[] %}

{% do sources_yaml.append('version: 2') %}
{% do sources_yaml.append('') %}
{% do sources_yaml.append('sources:') %}
{% do sources_yaml.append('  - name: ' ~ schema_name) %}
{% do sources_yaml.append('    tables:') %}

{% set tables=codegen.get_tables_in_schema(schema_name) %}

{% for table in tables %}
    {% do sources_yaml.append('      - name: ' ~ table) %}

{% endfor %}
{% if execute %}

    {{ log(sources_yaml | join ('\n'), info=True) }}

{% endif %}

{% endmacro %}
