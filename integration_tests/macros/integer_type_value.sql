{%- macro integer_type_value() -%}
{%- if target.type == "snowflake" -%}
NUMBER(38,0)
{%- else -%}
INTEGER
{%- endif -%}
{%- endmacro -%}
