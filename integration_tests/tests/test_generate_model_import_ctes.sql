{% set actual_model_with_import_ctes = codegen.generate_model_import_ctes(
    model_name = 'model_without_import_ctes'
  )
%}

{% set expected_model_with_import_ctes %}
/*
    This is my model!
*/

{% raw %}{{ config(
    materialized='table',
) }}{% endraw %}

with codegen_integration_tests__data_source_schema_codegen_integration_tests__data_source_table as (

    select * from codegen_integration_tests__data_source_schema.codegen_integration_tests__data_source_table
    -- CAUTION: It's best practice to use the ref or source function instead of a direct reference
  
),

data__a_relation as (

    select * from {% raw %}{{ ref('data__a_relation') }}{% endraw %}
  
),

data__b_relation as (

    select * from {% raw %}{{ ref("data__b_relation") }}{% endraw %}
  
),

development_codegen_integration_tests__data_source_schema_codegen_integration_tests__data_source_table as (

    select * from development.codegen_integration_tests__data_source_schema.codegen_integration_tests__data_source_table
    -- CAUTION: It's best practice to use the ref or source function instead of a direct reference
  
),

my_other_table_reference as (

    select * from {% raw %}{{ var("my_other_table_reference", "table_d") }}{% endraw %}
    -- CAUTION: It's best practice to use the ref or source function instead of a var
  
),

my_schema_raw_relation_5 as (

    select * from 'my_schema'.'raw_relation_5'
    -- CAUTION: It's best practice to use the ref or source function instead of a direct reference
  
),

my_table_reference as (

    select * from {% raw %}{{ var("my_table_reference") }}{% endraw %}
    -- CAUTION: It's best practice to use the ref or source function instead of a var
  
),

raw_relation_1 as (

    select * from `raw_relation_1`
    -- CAUTION: It's best practice to use the ref or source function instead of a direct reference
  
),

raw_relation_2 as (

    select * from "raw_relation_2"
    -- CAUTION: It's best practice to use the ref or source function instead of a direct reference
  
),

raw_relation_3 as (

    select * from [raw_relation_3]
    -- CAUTION: It's best practice to use the ref or source function instead of a direct reference
  
),

raw_relation_4 as (

    select * from 'raw_relation_4'
    -- CAUTION: It's best practice to use the ref or source function instead of a direct reference
  
),

source_codegen_integration_tests__data_source_table as (

    select * from {% raw %}{{ source('codegen_integration_tests__data_source_schema', 'codegen_integration_tests__data_source_table') }}{% endraw %} 
    -- CAUTION: It's best practice to create staging layer for raw sources
  
),

-- I love this cte
my_first_cte as (
    select
        a.col_a,
        b.col_b
    from data__a_relation as a
    left join data__b_relation as b
    on a.col_a = b.col_a
    left join data__a_relation as aa
    on a.col_a = aa.col_a
),
my_second_cte as (
    select
        1 as id
    from codegen_integration_tests__data_source_schema_codegen_integration_tests__data_source_table
    union all
    select
        2 as id
    from source_codegen_integration_tests__data_source_table
    -- union all 
    -- select
    --     3 as id
    -- from development_codegen_integration_tests__data_source_schema_codegen_integration_tests__data_source_table
    -- union all
    -- select
    --     4 as id
    -- from my_table_reference
    -- union all
    -- select
    --     5 as id
    -- from my_other_table_reference
)
-- my_third_cte as (
--     select
--         a.col_a,
--         b.col_b
--     from raw_relation_1 as a
--     left join raw_relation_2 as b
--     on a.col_a = b.col_b
--     left join raw_relation_3 as aa
--     on a.col_a = aa.col_b
--     left join raw_relation_4 as ab
--     on a.col_a = ab.col_b
--     left join my_schema_raw_relation_5 as ac
--     on a.col_a = ac.col_b
-- )
select * from my_second_cte
{% endset %}

{{ assert_equal (actual_model_with_import_ctes | trim, expected_model_with_import_ctes | trim) }}