/*
    This is my model!
*/

{{ config(
    materialized='table',
) }}

-- I love this cte
with my_first_cte as (
    select
        a.col_a,
        b.col_b
    from {{ ref('data__a_relation') }} as a
    left join      {{ ref("data__b_relation") }} as b
    on a.col_a = b.col_a
    left join {{ ref('data__a_relation') }} as aa
    on a.col_a = aa.col_a
),
my_second_cte as (
    select
        1 as id
    from {{ target.schema }}__data_source_schema.codegen_integration_tests__data_source_table
    union all
    select
        2 as id
    from {{ source('codegen_integration_tests__data_source_schema', 'codegen_integration_tests__data_source_table') }}
    -- union all 
    -- select
    --     3 as id
    -- from development.codegen_integration_tests__data_source_schema.codegen_integration_tests__data_source_table
    -- union all
    -- select
    --     4 as id
    -- from {{ var("my_table_reference") }}
    -- union all
    -- select
    --     5 as id
    -- from {{ var("my_other_table_reference", "table_d") }}
)
-- my_third_cte as (
--     select
--         a.col_a,
--         b.col_b
--     from `raw_relation_1` as a
--     left join "raw_relation_2" as b
--     on a.col_a = b.col_b
--     left join [raw_relation_3] as aa
--     on a.col_a = aa.col_b
--     left join 'raw_relation_4' as ab
--     on a.col_a = ab.col_b
--     left join 'my_schema'.'raw_relation_5' as ac
--     on a.col_a = ac.col_b
-- )
select * from my_second_cte