{%- macro integer_type_value() -%}
{%- if target.type == "snowflake" -%}
NUMBER(38,0)
{%- elif target.type == "bigquery" -%}
INT64
{%- else -%}
INTEGER
{%- endif -%}
{%- endmacro -%}
