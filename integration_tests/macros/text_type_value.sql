{%- macro text_type_value() -%}
{%- if target.type == "redshift" or target.type == "snowflake" -%}
character varying
{%- elif target.type == "bigquery" -%}
string
{%- else -%}
text
{%- endif -%}
{%- endmacro -%}
