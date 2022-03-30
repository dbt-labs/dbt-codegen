{# retrieve directly upstream models from a given model #}
{% macro get_model_dependencies(model_name) %}
    {% for node in graph.nodes.values() | selectattr('name', "equalto", model_name) %}
        {{ return(node.depends_on.nodes) }}
    {% endfor %}
{% endmacro %}


{# add to an input dictionnary entries containing all the column descriptions of a given model #}
{% macro add_model_column_descriptions_to_dict(model_name,dict_with_descriptions={}) %}
    {% for node in graph.nodes.values() | selectattr('name', "equalto", model_name) %}
        {% for col_name, col_values in node.columns.items() %}
            {% do dict_with_descriptions.update( {col_name: col_values.description} ) %}
        {% endfor %}
    {% endfor %}
    {{ return(dict_with_descriptions) }}
{% endmacro %}

{# build a global dictionnary looping through all the direct parents models #}
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