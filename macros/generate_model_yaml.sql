{% macro generate_column_yaml(column, model_yaml, column_desc_dict, include_data_types, parent_column_name="", case_sensitive_cols=False) %}
  {{ return(adapter.dispatch('generate_column_yaml', 'codegen')(column, model_yaml, column_desc_dict, include_data_types, parent_column_name, case_sensitive_cols)) }}
{% endmacro %}

{% macro default__generate_column_yaml(column, model_yaml, column_desc_dict, include_data_types, parent_column_name, case_sensitive_cols) %}
    {% if parent_column_name %}
        {% set full_column_name = parent_column_name ~ "." ~ column.name %}
    {% else %}
        {% set full_column_name = column.name %}
    {% endif %}
    {% set column_name = full_column_name if case_sensitive_cols else full_column_name | lower %}

    {% do model_yaml.append('      - name: ' ~ column_name ) %}
    {% if include_data_types %}
        {% do model_yaml.append('        data_type: ' ~ codegen.data_type_format_model(column)) %}
    {% endif %}
    {% do model_yaml.append('        description: ' ~ (column_desc_dict.get(column_name,'') | tojson)) %}
    {% do model_yaml.append('') %}

    {% if column.fields|length > 0 %}
        {% for child_column in column.fields %}
            {% set model_yaml = codegen.generate_column_yaml(child_column, model_yaml, column_desc_dict, include_data_types, parent_column_name=column_name, case_sensitive_cols=case_sensitive_cols) %}
        {% endfor %}
    {% endif %}
    {% do return(model_yaml) %}
{% endmacro %}

{% macro generate_model_yaml(model_names=[], upstream_descriptions=False, include_data_types=True, case_sensitive_models=False, case_sensitive_cols=False) -%}
  {{ return(adapter.dispatch('generate_model_yaml', 'codegen')(model_names, upstream_descriptions, include_data_types, case_sensitive_models, case_sensitive_cols)) }}
{%- endmacro %}

{% macro default__generate_model_yaml(model_names, upstream_descriptions, include_data_types, case_sensitive_models, case_sensitive_cols) %}

    {% set model_yaml=[] %}

    {% do model_yaml.append('version: 2') %}
    {% do model_yaml.append('') %}
    {% do model_yaml.append('models:') %}

    {% if model_names is string %}
        {{ exceptions.raise_compiler_error("The `model_names` argument must always be a list, even if there is only one model.") }}
    {% else %}
        {% for model in model_names %}
            {% set model_name = model if case_sensitive_models else model | lower %}
            {% do model_yaml.append('  - name: ' ~ model_name) %}
            {% do model_yaml.append('    description: ""') %}
            {% do model_yaml.append('    columns:') %}

            {% set relation=ref(model) %}
            {%- set columns = adapter.get_columns_in_relation(relation) -%}
            {% set column_desc_dict =  codegen.build_dict_column_descriptions(model, case_sensitive_cols) if upstream_descriptions else {} %}

            {% for column in columns %}
                {% set model_yaml = codegen.generate_column_yaml(column, model_yaml, column_desc_dict, include_data_types, case_sensitive_cols=case_sensitive_cols) %}
            {% endfor %}
        {% endfor %}
    {% endif %}

{% if execute %}

    {% set joined = model_yaml | join ('\n') %}
    {{ print(joined) }}
    {% do return(joined) %}

{% endif %}

{% endmacro %}