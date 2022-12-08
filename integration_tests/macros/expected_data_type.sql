{%- macro expected_data_type(data_type, size=none) -%}
  {%- if size -%}
    {{
      api.Column.from_description(
        name=none,
        raw_data_type=data_type ~ "(" ~ size ~ ")"
      )
    }}
  {%- else -%}
    {{ api.Column.create(data_type) }}
  {%- endif -%}
{%- endmacro -%}
