{%- macro text_type_value() -%}
{%- if target.type == "redshift"-%}
character varying
{%- if target.type == "snowflake" -%}
varchar
{%- elif target.type == "bigquery" -%}
string
{%- else -%}
text
{%- endif -%}
{%- endmacro -%}
