

with
    all_tables as (
        select distinct
            table_schema,
            table_name
        from columns
        where table_schema = 'CSPRD_SYSADM' 
    ),
    
    effdt_tables as (
        select
            table_schema,
            table_name,
            column_name,
            data_type as effdt_data_type
        from columns
        where table_schema = 'CSPRD_SYSADM' 
        and column_name = 'EFFDT'
    ),

    effseq_tables as (
        select
            table_name,
            column_name
        from columns
        where table_schema = 'CSPRD_SYSADM' 
        and column_name = '%EFFSEQ%'
    ),

    effdt_effseq_tables as (
        select
            all_tables.table_schema,
            all_tables.table_name,
            iff(effdt_tables.column_name is null, false, true) as is_effdt,
            effdt_tables.effdt_data_type,
            iff(effseq_tables.column_name is null, false, true) as is_effseq,
            case 
                when is_effdt = false then 'non-effective-dated'
                when is_effdt = true and effdt_data_type = 'DATE' and is_effseq = false then 'type-1'
                when is_effdt = true and effdt_data_type = 'DATE' and is_effseq = true then 'type-2'
                when is_effdt = true and effdt_data_type ilike '%TIMESTAMP%' and is_effseq = false then 'type-3'
                when is_effdt = true and effdt_data_type ilike '%TIMESTAMP%' and is_effseq = true then 'type-4'
            end as effective_type_table,
            case
                when effective_type_table = 'non-effective-dated' then 'stg_non_eff'
                when effective_type_table = 'type-1' then 'stg_eff_type_1'
                when effective_type_table = 'type-2' then 'stg_eff_type_2'
                when effective_type_table = 'type-3' then 'stg_eff_type_3_to_type_2'
                when effective_type_table = 'type-4' then 'stg_eff_type_2'
            end as staging_macro

        from all_tables
        left join effdt_tables
        using(table_name)
        left join effseq_tables
        using(table_name)
    )

select * from effdt_effseq_tables
order by 2

