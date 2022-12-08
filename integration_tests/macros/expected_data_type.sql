{%- macro expected_data_type(data_type, size=none) -%}
  {%- if size -%}
    {%-
      set column = api.Column.from_description(
        name=none,
        raw_data_type=data_type ~ "(" ~ size ~ ")"
      )
    -%}
  {%- else -%}
    {%- set column = api.Column.create(none, data_type) -%}
  {%- endif -%}
  {{ column.dtype }}
  {%- if column.string_size() and string_size != 256 -%}({{ column.string_size() }})
  {%- elif column.numeric_precision and column.numeric_scale -%}({{
    column.numeric_precision }},{{ column.numeric_scale }})
  {%- endif -%}
{%- endmacro -%}
