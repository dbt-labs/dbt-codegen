{% macro generate_column_yaml(column, model_yaml, column_desc_dict, include_data_types, parent_column_name="") %}
    {% if parent_column_name %}
        {% set column_name = parent_column_name ~ "." ~ column.name %}
    {% else %}
        {% set column_name = column.name %}
    {% endif %}

    {% do model_yaml.append('      - name: ' ~ column_name  | lower ) %}
    {% if include_data_types %}
        {% do model_yaml.append('        data_type: ' ~ codegen.data_type_format_model(column)) %}
    {% endif %}
    {% do model_yaml.append('        description: "' ~ column_desc_dict.get(column.name | lower,'') ~ '"') %}
    {% do model_yaml.append('') %}

    {% if column.fields|length > 0 %}
        {% for child_column in column.fields %}
            {% set model_yaml = codegen.generate_column_yaml(child_column, model_yaml, column_desc_dict, include_data_types, parent_column_name=column_name) %}
        {% endfor %}
    {% endif %}
    {% do return(model_yaml) %}
{% endmacro %}

{% macro generate_model_yaml(model_names=[], upstream_descriptions=False, include_data_types=True) %}

    {% set model_yaml=[] %}

    {% do model_yaml.append('version: 2') %}
    {% do model_yaml.append('') %}
    {% do model_yaml.append('models:') %}

    {% if model_names is string %}
        {{ exceptions.raise_compiler_error("The `model_names` argument must always be a list, even if there is only one model.") }}
    {% else %}
        {% for model in model_names %}
            {% do model_yaml.append('  - name: ' ~ model | lower) %}
            {% do model_yaml.append('    description: ""') %}
            {% do model_yaml.append('    columns:') %}

            {% set relation=ref(model) %}
            {%- set columns = adapter.get_columns_in_relation(relation) -%}
            {% set column_desc_dict =  codegen.build_dict_column_descriptions(model) if upstream_descriptions else {} %}

            {% for column in columns %}
                {% set model_yaml = codegen.generate_column_yaml(column, model_yaml, column_desc_dict, include_data_types) %}
            {% endfor %}
        {% endfor %}
    {% endif %}

{% if execute %}

    {% set joined = model_yaml | join ('\n') %}
    {{ log(joined, info=True) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}