{%- macro text_type_value(text_length) -%}
{%- if target.type == "redshift" -%}
character varying({{ text_length }})
{%- elif target.type == "snowflake" -%}
character varying(16777216)
{%- elif target.type == "bigquery" -%}
string
{%- else -%}
text
{%- endif -%}
{%- endmacro -%}
