
{% set actual_base_model = codegen.generate_base_model(
    source_name='codegen_integration_tests__data_source_schema',
    table_name='codegen_integration_tests__data_source_table',
    leading_commas=True
  )
%}

{% set expected_base_model %}
{{ "{{ config(materialized='table') }}" }}

with source as (

    select * from {%raw%}{{ source('codegen_integration_tests__data_source_schema', 'codegen_integration_tests__data_source_table') }}{%endraw%}

),

renamed as (

    select
        my_integer_col
        , my_bool_col

    from source

)

select * from renamed
{% endset %}

{{ assert_equal (actual_base_model | trim, expected_base_model | trim) }}
