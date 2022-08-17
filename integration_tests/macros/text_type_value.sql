{%- macro text_type_value(text_length) -%}
{%- if target.type == "redshift" -%}
CHARACTER VARYING({{ text_length }})
{%- elif target.type == "snowflake" -%}
CHARACTER VARYING(16777216)
{%- elif target.type == "bigquery" -%}
STRING
{%- else -%}
TEXT
{%- endif -%}
{%- endmacro -%}
