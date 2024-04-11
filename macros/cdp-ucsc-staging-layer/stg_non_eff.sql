{# dbt run-operation --quiet stg_non_eff --args '{"source_name": "campus_solutions", "table_name": "ps_aa_override"}'  #}

{% macro stg_non_eff(source_name, table_name, alphabetize=true) %}

{# GET ALL COLUMNS FROM SOURCE TABLE (this information comes from the database)#}
{%- set source_relation = source(source_name, table_name) -%}
{%- set columns = adapter.get_columns_in_relation(source_relation) -%}

{# CONDITIONAL ALPHABETIZATION OF THE LOWER CASED COLUMN LIST #}
{% if alphabetize %}
    {%- set col_names = columns | map(attribute='name') | map('lower') | sort -%}
{% else %}
    {%- set col_names = columns | map(attribute='name') | map('lower') | list -%}
{% endif %}

{# DECLARE EMPTY VARIABLES THAT WILL STORE COLUMN META INFORMATION FROM THE MANIFEST.JSON #}
{%- set col_renamed_as = {} -%}
{%- set col_casted_as =  {} -%}
{%- set soft_delete_cols = [] -%}

{# USE GRAPH CONTEXT VARIABLE TO GET TABLE INFORMATION FROM THE MANIFEST.JSON WHICH REFLECTS PROP AND CONFIG DECLARATIONS IN THE SOURCE.YML #}
{%- for table_attributes in graph.sources.values() | selectattr("name", "equalto", table_name) -%}

    {# GET COLUMN AND COLUMN INFORMATION FROM THE GRAPH CONTEXT VARIABLE #}
    {%- for col, col_attr in table_attributes.columns | items -%}
        {# (1) IF THERE IS A RENAMED_AS VALUE DECLARED UNDER META, CREATE A DICTIONARY WITH THE COLUMN AND VALUE #}
        {%- if col_attr.meta.renamed_as %}
            {% do col_renamed_as.update ({col : col_attr.meta.renamed_as}) %}
        {%- endif %}
        {# (2) IF THERE IS A CASTED_AS VALUE DECLARED UNDER META, CREATE A DICTION WITH THE COLUMN AND VALUE #}
        {%- if col_attr.meta.casted_as %}
            {% do col_casted_as.update ({col : col_attr.meta.casted_as}) %}
        {%- endif %}
    {%- endfor -%}

    {# GET THE SOFT DELETE TRACKING COLUMNS AND THEIR CONDITIONS #}
    {% for i in table_attributes.source_meta.soft_delete_columns %}
    {% do soft_delete_cols.append(i) %}
    {% endfor %}

{%- endfor %}

{# GENERATE THE STAGING MODEL BODY #}
{%- set stg_non_eff -%}
/*  The source for this model is: {{source_name}}
*/

with
    source as (
        select * from {% raw -%} {{ source( {%- endraw -%} '{{ source_name }}', '{{ table_name }}' {%- raw -%} ) }}{% endraw %}
        {%- if soft_delete_cols[0] %}
        where
            {{ soft_delete_cols | join('\nand ') | indent(12) }}
        {%- endif %}
    ),

    transformation as (
        select
        {%- for i in col_names %}
            {# (1) CAST AND RENAME #}
            {%- if col_casted_as[i] and col_renamed_as[i] -%}
            cast({{i}} as {{col_casted_as[i]}}) as {{col_renamed_as[i]}}{{',' if not loop.last}}
            {#- (2) CAST ONLY #}
            {%- elif col_casted_as[i] and not col_renamed_as[i] -%}
            cast({{i}} as {{col_casted_as[i]}}) as {{i}}{{',' if not loop.last}}
            {#- (3) RENAME ONLY #}
            {%- elif not col_casted_as[i] and col_renamed_as[i] -%}
            {{i}} as {{col_renamed_as[i]}}{{',' if not loop.last}}
            {#- (4) NO TRANSFORMATION #}
            {%- else -%}
            {{i}}{{ ',' if not loop.last}}
            {%- endif -%}
        {%- endfor %}

        from source
    )

select * from transformation

{%- endset -%}

    {%- if execute -%}
        {{ print(stg_non_eff) }}
        {% do return(stg_non_eff) %}
    {%- endif -%}

{%- endmacro -%}