
{% set actual_base_model = codegen.generate_base_model(
    source_name='codegen_integration_tests__data_source_schema',
    table_name='codegen_integration_tests__data_source_table_case_sensitive',
    leading_commas=True,
    case_sensitive_cols=True,
    materialized='table'
  )
%}

{% set expected_base_model %}
{{ "{{ config(materialized='table') }}" }}

with source as (

    select * from {%raw%}{{ source('codegen_integration_tests__data_source_schema', 'codegen_integration_tests__data_source_table_case_sensitive') }}{%endraw%}

),

renamed as (

    select
        {{ adapter.quote("My_Integer_Col") }}
        , {{ adapter.quote("My_Bool_Col") }}

    from source

)

select * from renamed
{% endset %}

{{ assert_equal (actual_base_model | trim, expected_base_model | trim) }}
