{# dbt run-operation --quiet stage_banner_eff_nchg_date_tables --args '{"source_name": "fis", "table_name": "frrbasi", "alphabetize": true}' #}

{% macro stage_banner_eff_nchg_date_tables(source_name, table_name, partition_columns, alphabetize=true) %}

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
{% set ns = namespace() %} {# Use namespace so ns.eff_col can persist outside of the for loop it is defined in #}
{%- set ns.eff_col = "" -%}
{%- set ns.eff_col_renamed_as = "" -%}
{%- set ns.nchg_col_renamed_as = "" -%}
{%- set partition_cols = [] -%}
{%- set col_casted_as =  {} -%}
{%- set col_renamed_as = {} -%}
{%- set soft_delete_cols = [] -%}

{# USE GRAPH CONTEXT VARIABLE TO GET TABLE INFORMATION FROM THE MANIFEST.JSON WHICH REFLECTS PROP. AND CONFIG. DECLARATIONS IN THE SOURCE.YML #}
{%- for table_attributes in graph.sources.values() | selectattr("name", "equalto", table_name) -%}
    {# GET THE MODEL'S EFFECTIVE DATE COLUMN FROM THE GRAPH CONTEXT VARIABLE #}
    {% set ns.eff_col = table_attributes.meta.effective_date_col %}

    {# GET THE MODEL'S PARTITION COLUMNS FROM THE GRAPH CONTEXT VARIABLE #}
    {% for i in table_attributes.meta.partition_columns %}
    {% do partition_cols.append(i) %}
    {% endfor %}

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

{# FIELDS THAT NEED TO BE REFERENCED DIRECTLY THAT ARE DOWNSTREAM FROM THE TRANSFORMATION CTE NEED TO BE REFERRED TO USING THEIR NEW NAMES. THESE RENAMED VARIABLES OF THE THE ORIGINAL VARIABLES WILL BE USED IN ANY CTE AFTER THE TRANSFORMATION CTE. #}
{%- if col_renamed_as[ns.eff_col] -%}
{%- set ns.eff_col_renamed_as = col_renamed_as[ns.eff_col] -%}
{%- else -%}
{%- set ns.eff_col_renamed_as = ns.eff_col -%}
{%- endif -%}

{%- set nchg_col = table_name ~ '_nchg_date' -%}
{%- if col_renamed_as[nchg_col] -%}
{%- set ns.nchg_col_renamed_as = col_renamed_as[nchg_col] -%}
{%- else -%}
{%- set ns.nchg_col_renamed_as = nchg_col -%}
{%- endif -%}

{%- set stage_banner_eff_nchg_date_tables -%}

with
    source as (
        select * from {% raw -%} {{ source( {%- endraw -%} '{{ source_name }}', '{{ table_name }}' {%- raw -%} ) }}{% endraw %}
        {%- if soft_delete_cols[0] %}
        where
            {{ soft_delete_cols | join('\nand ') | indent(12) }}
        {%- endif %}
    ),

    derive_effseq_and_transform as (
        -- Derive a sequence number for records that share the same effective day
        select
        {%- for i in col_names %}
            {# (1) CAST AND RENAME #}
            {%- if col_casted_as[i] and col_renamed_as[i] -%}
            cast({{i}} as {{col_casted_as[i]}}) as {{col_renamed_as[i]}},
            {#- (2) CAST ONLY #}
            {%- elif col_casted_as[i] and not col_renamed_as[i] -%}
            cast({{i}} as {{col_casted_as[i]}}) as {{i}},
            {#- (3) RENAME ONLY #}
            {%- elif not col_casted_as[i] and col_renamed_as[i] -%}
            {{i}} as {{col_renamed_as[i]}},
            {#- (4) NO TRANSFORMATION #}
            {%- else -%}
            {{i}},
            {%- endif -%}
        {%- endfor %}
            row_number() over (
                partition by
                    {{ partition_cols | join(',\n') | indent(20) }},
                    cast({{ns.eff_col}} as date)
                order by
                    {{ns.eff_col}}
            ) as {{table_name}}_effseq,
            count(*) over (
                partition by
                    {{ partition_cols | join(',\n') | indent(20) }},
                    cast({{ns.eff_col}} as date)
            ) as {{table_name}}_max_effseq

        from source
    ),

    final as (
        select
            derive_effseq_and_transform.*,

            -- New Objects
            cast(derive_effseq_and_transform.{{ns.eff_col_renamed_as}} as date) as valid_from,
            coalesce(cast(derive_effseq_and_transform.{{ns.nchg_col_renamed_as}} as date), '2099-12-31') as valid_to,
            derive_effseq_and_transform.{{table_name}}_effseq
            = derive_effseq_and_transform.{{table_name}}_max_effseq as is_max_rcd_of_effdt,
            case
                when valid_from > {{'{{'}} var("current_date_pst") {{'}}'}} then 'future'
                when valid_to < {{'{{'}} var("current_date_pst") {{'}}'}} then 'past'
                when valid_to >= {{'{{'}} var("current_date_pst") {{'}}'}}
                    and is_max_rcd_of_effdt = true
                    then 'current'
                when valid_to >= {{'{{'}} var("current_date_pst") {{'}}'}}
                    and is_max_rcd_of_effdt = false
                    then 'past'
            end as current_record_desc,
            case
                when current_record_desc = 'current' then true
                when current_record_desc in ('future', 'past') then false
            end as is_current_record

        from derive_effseq_and_transform
    )

select * from final

{%- endset -%}


{%- if execute -%}
    {{ print(stage_banner_eff_nchg_date_tables) }}
    {%- do return(stage_banner_eff_nchg_date_tables) -%}
{%- endif -%}

{%- endmacro -%}