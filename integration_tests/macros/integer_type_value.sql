{%- macro integer_type_value() -%}
{%- if target.type == "snowflake" -%}
number
{%- elif target.type == "bigquery" -%}
int64
{%- else -%}
integer
{%- endif -%}
{%- endmacro -%}
