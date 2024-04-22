{# dbt run-operation --quiet stg_eff_type_2 --args '{"source_name": "campus_solutions", "table_name": "ps_aa_override", "alphabetize": true}' #}

{% macro stg_eff_type_2(source_name, table_name, alphabetize=true) %}

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
{%- set ns.eff_seq_col = "" -%}
{%- set ns.eff_seq_col_renamed_as = "" -%}
{%- set ns.eff_seq_order = "" -%}
{%- set ns.min_or_max = "" -%}
{%- set partition_cols = [] -%}
{%- set partition_cols_renamed_as = [] -%}
{%- set col_casted_as =  {} -%}
{%- set col_renamed_as = {} -%}
{%- set soft_delete_cols = [] -%}

{# USE GRAPH CONTEXT VARIABLE TO GET TABLE INFORMATION FROM THE MANIFEST.JSON WHICH REFLECTS PROP AND CONFIG DECLARATIONS IN THE SOURCE.YML #}
{%- for table_attributes in graph.sources.values() | selectattr("name", "equalto", table_name) -%}
    {# GET THE MODEL'S EFFECTIVE DATE COLUMN FROM THE GRAPH CONTEXT VARIABLE #}
    {% set ns.eff_col = table_attributes.meta.effective_date_col %}

    {# GET THE MODEL'S EFFECTIVE SEQUENCE AND ORDER COLUMNS FROM THE GRAPH CONTEXT VARIABLE #}
    {% set ns.eff_seq_col = table_attributes.meta.effective_sequence_col %}
    {% set ns.eff_seq_order = table_attributes.meta.effective_sequence_order %}

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

{%- if col_renamed_as[ns.eff_seq_col] -%}
{%- set ns.eff_seq_col_renamed_as = col_renamed_as[ns.eff_seq_col] -%}
{%- else -%}
{%- set ns.eff_seq_col_renamed_as = ns.eff_seq_col -%}
{%- endif -%}

{%- for i in partition_cols -%}
{%- if col_renamed_as[i] -%}
{%- do partition_cols_renamed_as.append(col_renamed_as[i]) -%}
{%- else -%}
{%- do partition_cols_renamed_as.append(i) -%}
{%- endif -%}
{%- endfor -%}

{# DETERMINE WHETHER TO USE MAX() OR MIN() TO ID THE LATTER RECORD IN A SEQUENCE OF RECORDS BASED ON THE SEQUENCE ORDER #}
{%- if ns.eff_seq_order == 'asc' -%}
{%- set ns.min_or_max = "max" -%}
{%- elif ns.eff_seq_order == 'desc' -%}
{%- set ns.min_or_max = "min" -%}
{%- endif -%}

{# GENERATE THE STAGING MODEL BODY #}
{%- set stg_eff_type_2 -%}
/*  The partition columns are: {{partition_cols}}
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
    ),

    valid_to as (
        -- Group the records so that each group belonging to one effdt gets the same valid_to date
        select
            {{ partition_cols_renamed_as | join(',\n') | indent(12) }},
            {{ns.eff_col_renamed_as}},
            coalesce((lag({{ns.eff_col_renamed_as}}, 1) over (
                partition by
                    {{ partition_cols_renamed_as | join(',\n') | indent(20) }}
                order by {{ns.eff_col_renamed_as}} desc
            ) - 1), '2099-12-31') as valid_to

        from transformation
        group by
            {% for i in partition_cols_renamed_as -%}
                            {{loop.index}},
            {{loop.index + 1 if loop.last }}
            {%- endfor %}
    ),

    final as (
        select
            transformation.*,

            -- New Objects
            transformation.{{ns.eff_col_renamed_as}} as valid_from,
            {{ns.min_or_max}}(transformation.{{ns.eff_seq_col_renamed_as}}) over (
                partition by
                    transformation.{{ partition_cols_renamed_as | list | join(',\ntransformation.') | indent(20) }},
                    transformation.{{ns.eff_col_renamed_as}}
            ) as {{ns.min_or_max}}_effseq_of_effdt,
            transformation.{{ns.eff_seq_col_renamed_as}} = {{ns.min_or_max}}_effseq_of_effdt as is_latter_rcd_of_effdt,
            case
                when is_latter_rcd_of_effdt then valid_to.valid_to
                else transformation.{{ns.eff_col_renamed_as}}
            end as valid_to,
            case
                when valid_from > {{'{{'}} var("current_date_pst") {{'}}'}} then 'future'
                when valid_to.valid_to < {{'{{'}} var("current_date_pst") {{'}}'}} then 'past'
                when valid_to.valid_to >= {{'{{'}} var("current_date_pst") {{'}}'}}
                    and is_latter_rcd_of_effdt = true
                    then 'current'
                when valid_to.valid_to >= {{'{{'}} var("current_date_pst") {{'}}'}}
                    and is_latter_rcd_of_effdt = false
                    then 'past'
            end as current_record_desc,
            case
                when current_record_desc = 'current' then true
                when current_record_desc in ('future', 'past') then false
            end as is_current_record

            {%- if "setid" in partition_cols_renamed_as and "estabid" in partition_cols_renamed_as -%}
            ,

            'verification_needed' as is_ucsc_record

            {%- elif "setid" in partition_cols_renamed_as -%}
            ,

            transformation.setid in ('SCCMP', 'SCFIN', 'UCSHR') as is_ucsc_record,
            case
                when is_ucsc_record = false
                    then 'other campus specific'
                when is_ucsc_record = true
                    and transformation.setid in ('SCCMP', 'SCFIN')
                    then 'ucsc specific'
                when is_ucsc_record = true
                    and transformation.setid = 'UCSHR'
                    then 'shared system wide'
            end as ucsc_record_desc

            {%- elif "estabid" in partition_cols_renamed_as -%}
            ,

            case when transformation.estabid = 'UCSC' then true else false end as is_ucsc_record,
            case when is_ucsc_record = true then 'ucsc specific' else 'other campus specific' end as ucsc_record_desc
            {% endif %}

        from transformation

        left outer join valid_to
            {% for i in partition_cols_renamed_as -%}
            {{'on' if loop.first else '\n                and'}} transformation.{{i}} = valid_to.{{i}}{% endfor %}
                and transformation.{{ns.eff_col_renamed_as}} = valid_to.{{ns.eff_col_renamed_as}}
    )

select * from final
{%- endset -%}


{%- if execute -%}
    {{ print(stg_eff_type_2) }}
    {%- do return(stg_eff_type_2) -%}
{%- endif -%}

{%- endmacro -%}