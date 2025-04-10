{%- macro bool_type_value(case_sensitive=False) -%}
{%- if target.type == "redshift" -%}
    {%- if case_sensitive -%}BOOLEAN{%- else -%}boolean{%- endif -%}
{%- elif target.type == "snowflake" -%}
    {%- if case_sensitive -%}BOOLEAN{%- else -%}boolean{%- endif -%}
{%- elif target.type == "bigquery" -%}
    {%- if case_sensitive -%}BOOL{%- else -%}bool{%- endif -%}
{%- elif target.type == "postgres" -%}
    boolean
{%- else -%}
    {%- if case_sensitive -%}BOOLEAN{%- else -%}boolean{%- endif -%}
{%- endif -%}
{%- endmacro -%} 