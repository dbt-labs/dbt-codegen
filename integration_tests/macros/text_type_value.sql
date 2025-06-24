{%- macro text_type_value(case_sensitive=False) -%}
{%- if target.type == "redshift"-%}
    character varying
{%- elif target.type == "snowflake" -%}
    {%- if case_sensitive -%}VARCHAR{%- else -%}varchar{%- endif -%}
{%- elif target.type == "bigquery" -%}
    {%- if case_sensitive -%}STRING{%- else -%}string{%- endif -%}
{%- elif target.type == "postgres" -%}
    text
{%- else -%}
    {%- if case_sensitive -%}TEXT{%- else -%}text{%- endif -%}
{%- endif -%}
{%- endmacro -%}