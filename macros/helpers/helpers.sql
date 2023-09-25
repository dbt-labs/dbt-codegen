{# retrieve models directly upstream from a given model #}
{% macro get_model_dependencies(model_name) %}
    {% for node in graph.nodes.values() | selectattr('name', "equalto", model_name) %}
        {{ return(node.depends_on.nodes) }}
    {% endfor %}
{% endmacro %}


{# add to an input dictionary entries containing all the column descriptions of a given model #}
{% macro add_model_column_descriptions_to_dict(model_name,dict_with_descriptions={}) %}
    {% for node in graph.nodes.values() | selectattr('name', "equalto", model_name) %}
        {% for col_name, col_values in node.columns.items() %}
            {% do dict_with_descriptions.update( {col_name: col_values.description} ) %}
        {% endfor %}
    {% endfor %}
    {{ return(dict_with_descriptions) }}
{% endmacro %}

{# build a global dictionary looping through all the direct parents models #}
{# if the same column name exists with different descriptions it is overwritten at each loop #}
{% macro build_dict_column_descriptions(model_name) %}
    {% if execute %}
        {% set glob_dict = {} %}
        {% for full_model in codegen.get_model_dependencies(model_name) %}
            {% do codegen.add_model_column_descriptions_to_dict(full_model.split('.')[-1],glob_dict) %}
        {% endfor %}
        {{ return(glob_dict) }}
    {% endif %}
{% endmacro %}

{# build a list of models looping through all models in the project #}
{# filter by directory or prefix arguments, if provided #}
{% macro get_models(directory=None, prefix=None) %}
    {% set model_names=[] %}
    {% set models = graph.nodes.values() | selectattr('resource_type', "equalto", 'model') %}
    {% if directory and prefix %}
        {% for model in models %}
            {% set model_path = "/".join(model.path.split("/")[:-1]) %}
            {% if model_path == directory and model.name.startswith(prefix) %}
                {% do model_names.append(model.name) %}
            {% endif %} 
        {% endfor %}
    {% elif directory %}
        {% for model in models %}
            {% set model_path = "/".join(model.path.split("/")[:-1]) %}
            {% if model_path == directory %}
                {% do model_names.append(model.name) %}
            {% endif %}
        {% endfor %}
    {% elif prefix %}
        {% for model in models if model.name.startswith(prefix) %}
            {% do model_names.append(model.name) %}
        {% endfor %}
    {% else %}
        {% for model in models %}
            {% do model_names.append(model.name) %}
        {% endfor %}
    {% endif %}
    {{ return(model_names) }}
{% endmacro %}

{% macro data_type_format_source(column) -%}
  {{ return(adapter.dispatch('data_type_format_source', 'codegen')(column)) }}
{%- endmacro %}

{# format a column data type for a source #}
{% macro default__data_type_format_source(column) %}
    {% set formatted = codegen.format_column(column) %}
    {{ return(formatted['data_type'] | lower) }}
{% endmacro %}

{% macro data_type_format_model(column) -%}
  {{ return(adapter.dispatch('data_type_format_model', 'codegen')(column)) }}
{%- endmacro %}

{# format a column data type for a model #}
{% macro default__data_type_format_model(column) %}
    {% set formatted = codegen.format_column(column) %}
    {{ return(formatted['data_type'] | lower) }}
{% endmacro %}
