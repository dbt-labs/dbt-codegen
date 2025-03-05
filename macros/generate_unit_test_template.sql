{% macro generate_unit_test_template(model_name, expected_rows=true) %}

    {%- set ns = namespace(depends_on_list = []) -%}

    -- getting inputs and materialization info
    {%- for node in graph.nodes.values()
        | selectattr("resource_type", "equalto", "model")
        | selectattr("name", "equalto", model_name) -%}
        {%- set ns.depends_on_list = ns.depends_on_list + node.depends_on.nodes -%}
        {%- set ns.this_materialization = node.config['materialized'] -%}
    {%- endfor -%}

    -- getting the input columns
    {%- set ns.input_columns_list = [] -%}
    {%- for item in ns.depends_on_list -%}
        {%- set input_columns_list = [] -%}
        {%- set item_dict = get_resource_from_unique_id(item) -%}
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
    {%- set ns.expected_columns_list = [] -%}
    {%- set columns = adapter.get_columns_in_relation(ref(model_name)) -%}
    {%- for column in columns -%}
        {{ ns.expected_columns_list.append(column.name) }}
    {%- endfor -%}

    {%- set unit_test_yaml_template -%}
unit_tests:
  - name: unit_test_{{ model_name }}
    model: {{ model_name }}
    {% if ns.this_materialization == 'incremental' %}
    overrides:
      macros:
        is_incremental: true
    {% endif %}
    given:
    {%- for i in range(ns.depends_on_list|length) -%}
        {%- set item_dict = get_resource_from_unique_id(ns.depends_on_list[i]) -%}
        {% if item_dict.resource_type == 'source' %}
      - input: source("{{item_dict.source_name}}", "{{item_dict.identifier}}")
        rows:
        {%- else %}
      - input: ref("{{item_dict.alias}}")
        rows:
        {%- endif -%}
        {%- set ns.column_string = '- {' -%}
        {%- for column_name in ns.input_columns_list[i] -%}
            {%- if not loop.last -%}
                {%- set ns.column_string = ns.column_string ~ column_name ~ ': , ' -%}
            {%- else -%}
                {%- set ns.column_string = ns.column_string ~ column_name ~ ': }' -%}
            {%- endif -%}
        {% endfor %}
          {{ns.column_string}}
    {% endfor %}

    {%- if ns.this_materialization == 'incremental' -%}
      - input: this
        rows:
        {%- if expected_rows -%}
        {%- set ns.column_string = '- {' -%}
        {%- for column_name in ns.expected_columns_list -%}
              {%- if not loop.last -%}
                  {%- set ns.column_string = ns.column_string ~ column_name ~ ': , ' -%}
              {%- else -%}
                  {%- set ns.column_string = ns.column_string ~ column_name ~ ': }' -%}
              {%- endif -%}
              {% endfor %}
          {{ns.column_string}}
        {% endif %}
    {% endif %}

    expect:
      rows:
        {%- if expected_rows -%}
        {%- set ns.column_string = '- {' -%}
        {%- for column_name in ns.expected_columns_list -%}
            {%- if not loop.last -%}
                {%- set ns.column_string = ns.column_string ~ column_name ~ ': , ' -%}
            {%- else -%}
                {%- set ns.column_string = ns.column_string ~ column_name ~ ': }' -%}
            {%- endif -%}
        {% endfor %}
        {{ns.column_string}}
    {%- endif -%}

    {%- endset -%}

    {{ print(unit_test_yaml_template) }}

{% endmacro %}