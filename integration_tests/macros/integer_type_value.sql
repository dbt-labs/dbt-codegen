{%- macro integer_type_value(case_sensitive=False) -%}
{%- if target.type == "snowflake" -%}
    {%- if case_sensitive -%}NUMBER{%- else -%}number{%- endif -%}
{%- elif target.type == "bigquery" -%}
    {%- if case_sensitive -%}INT64{%- else -%}int64{%- endif -%}
{%- elif target.type == "postgres" -%}
    integer
{%- else -%}
    {%- if case_sensitive -%}INTEGER{%- else -%}integer{%- endif -%}
{%- endif -%}
{%- endmacro -%}
