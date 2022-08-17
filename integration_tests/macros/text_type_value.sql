{%- macro text_type_value(text_length) -%}
{%- if target.type == "redshift" -%}
CHARACTER VARYING({{ text_length }})
{%- else -%}
TEXT
{%- endif -%}
{%- endmacro -%}
