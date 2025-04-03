{% macro generate_unit_test_template(model_name, inline_columns=false) %}
  {{ return(adapter.dispatch('generate_unit_test_template', 'codegen')(model_name, inline_columns)) }}
{% endmacro %}

{% macro default__generate_unit_test_template(model_name, inline_columns=false) %}

    {%- set ns = namespace(depends_on_list = []) -%}

    {%- if execute -%}

    -- getting inputs and materialization info
    {%- for node in graph.nodes.values()
        | selectattr("resource_type", "equalto", "model")
        | selectattr("name", "equalto", model_name) -%}
        {%- set ns.depends_on_list = ns.depends_on_list + node.depends_on.nodes -%}
        {%- set ns.this_materialization = node.config['materialized'] -%}
    {%- endfor -%}

    {%- endif -%}

    -- getting the input columns
    {%- set ns.input_columns_list = [] -%}
    {%- for item in ns.depends_on_list -%}
        {%- set input_columns_list = [] -%}
        {%- set item_dict = codegen.get_resource_from_unique_id(item) -%}
        {%- if item_dict.resource_type == 'source' %}
            {%- set columns = adapter.get_columns_in_relation(source(item_dict.source_name, item_dict.identifier)) -%}
        {%- else -%}
            {%- set columns = adapter.get_columns_in_relation(ref(item_dict.alias)) -%}
        {%- endif -%}
        {%- for column in columns -%}
            {{ input_columns_list.append(column.name) }}
        {%- endfor -%}
        {{ ns.input_columns_list.append(input_columns_list) }}
    {%- endfor -%}

    -- getting 'this' columns
    {% set relation_exists = load_relation(ref(model_name)) is not none %}
    {% if relation_exists %}
        {%- set ns.expected_columns_list = [] -%}
        {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
        {%- for column in columns -%}
            {{ ns.expected_columns_list.append(column.name) }}
        {%- endfor -%}
    {% endif %}

    {%- set unit_test_yaml_template -%}
unit_tests:
  - name: unit_test_{{ model_name }}
    model: {{ model_name }}
{% if ns.this_materialization == 'incremental' %}
    overrides:
      macros:
        is_incremental: true
{% else -%}

{%- endif %}
    given: {%- if ns.depends_on_list|length == 0 and ns.this_materialization != 'incremental' %} []{% endif %}
    {%- for i in range(ns.depends_on_list|length) -%}
        {%- set item_dict = codegen.get_resource_from_unique_id(ns.depends_on_list[i]) -%}
        {% if item_dict.resource_type == 'source' %}
      - input: source("{{item_dict.source_name}}", "{{item_dict.identifier}}")
        rows:
        {%- else %}
      - input: ref("{{item_dict.alias}}")
        rows:
        {%- endif -%}
        {%- if inline_columns -%}
            {%- set ns.column_string = '- {' -%}
            {%- for column_name in ns.input_columns_list[i] -%}
                {%- if not loop.last -%}
                    {%- set ns.column_string = ns.column_string ~ column_name ~ ': , ' -%}
                {%- else -%}
                    {%- set ns.column_string = ns.column_string ~ column_name ~ ': }' -%}
                {%- endif -%}
            {% endfor %}
        {%- else -%}
            {%- set ns.column_string = '' -%}
            {%- for column_name in ns.input_columns_list[i] -%}
                {%- if loop.first -%}
                    {%- set ns.column_string = ns.column_string ~ '- ' ~ column_name ~ ': ' -%}
                {%- else -%}
                    {%- set ns.column_string = ns.column_string ~ '\n            ' ~ column_name ~ ': ' -%}
                {%- endif -%}
            {% endfor %}
        {%- endif %}
          {{ns.column_string}}
    {%- endfor %}

    {%- if ns.this_materialization == 'incremental' %}
      - input: this
        rows:
        {%- if relation_exists -%}
            {%- if inline_columns -%}
                {%- set ns.column_string = '- {' -%}
                {%- for column_name in ns.expected_columns_list -%}
                    {%- if not loop.last -%}
                        {%- set ns.column_string = ns.column_string ~ column_name ~ ': , ' -%}
                    {%- else -%}
                        {%- set ns.column_string = ns.column_string ~ column_name ~ ': }' -%}
                    {%- endif -%}
                {% endfor %}
            {%- else -%}
                {%- set ns.column_string = '' -%}
                {%- for column_name in ns.expected_columns_list -%}
                    {%- if loop.first -%}
                        {%- set ns.column_string = ns.column_string ~ '- ' ~ column_name ~ ': ' -%}
                    {%- else -%}
                        {%- set ns.column_string = ns.column_string ~ '\n            ' ~ column_name ~ ': ' -%}
                    {%- endif -%}
                {% endfor %}
            {%- endif %}
          {{ns.column_string}}
        {%- endif %}
    {%- endif %}

    expect:
      rows:
        {%- if relation_exists -%}
            {%- if inline_columns -%}
                {%- set ns.column_string = '- {' -%}
                {%- for column_name in ns.expected_columns_list -%}
                    {%- if not loop.last -%}
                        {%- set ns.column_string = ns.column_string ~ column_name ~ ': , ' -%}
                    {%- else -%}
                        {%- set ns.column_string = ns.column_string ~ column_name ~ ': }' -%}
                    {%- endif -%}
                {% endfor %}
            {%- else -%}
                {%- set ns.column_string = '' -%}
                {%- for column_name in ns.expected_columns_list -%}
                    {%- if loop.first -%}
                        {%- set ns.column_string = ns.column_string ~ '- ' ~ column_name ~ ': ' -%}
                    {%- else -%}
                        {%- set ns.column_string = ns.column_string ~ '\n          ' ~ column_name ~ ': ' -%}
                    {%- endif -%}
                {% endfor %}
            {%- endif %}
        {{ns.column_string}}
    {%- endif -%}

    {%- endset -%}

    {% if execute %}

        {{ print(unit_test_yaml_template) }}
        {% do return(unit_test_yaml_template) %}

    {% endif %}

{% endmacro %}
