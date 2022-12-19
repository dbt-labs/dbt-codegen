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

{% macro generate_source_column_yaml(column, model_yaml, parent_column_name="") %}
    {% if parent_column_name %}
        {% set column_name = parent_column_name ~ "." ~ column.name %}
    {% else %}
        {% set column_name = column.name %}
    {% endif %}

    {% do model_yaml.append('         - name: ' ~ column_name | lower ) %}
    {% do model_yaml.append('           description: "' ~ '"') %}

    {% if column.fields|length > 0 %}
        {% for child_column in column.fields %}
            {% set model_yaml = codegen.generate_source_column_yaml(child_column, model_yaml, parent_column_name=column_name) %}
        {% endfor %}
    {% endif %}
    {% do return(model_yaml) %}
{% endmacro %}

---
{% macro generate_source(schema_name, database_name=target.database, generate_columns=False, include_descriptions=False, table_pattern='%', exclude='', name=schema_name, table_names=None) %}

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
            {% set sources_yaml = codegen.generate_source_column_yaml(column, sources_yaml) %}
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
