{% macro generate_columns_yaml(relation) %}
{% set column_yaml=[] %}

{% set columns = adapter.get_columns_in_relation(relation) %}

{% for column in columns %}
    {% do column_yaml.append('      - name: ' ~ column.name | lower ) %}
    {% do column_yaml.append('        description: ' ~ column.name | lower | replace('_',' ')) %}
    {% do column_yaml.append('') %}
{% endfor %}

{{ return(column_yaml | join ('\n'))  }}

{% endmacro %}
