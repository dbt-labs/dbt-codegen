{% set actual_base_model = codegen.generate_base_model(
    source_name='codegen_integration_tests__data_source_schema',
    table_name='codegen_integration_tests__data_source_table_case_sensitive',
    case_sensitive_cols=True
  )
%}

{% set expected_base_model %}

with source as (

    select * from {%raw%}{{ source('codegen_integration_tests__data_source_schema', 'codegen_integration_tests__data_source_table_case_sensitive') }}{%endraw%}

),

renamed as (

    select
        {% if target.type == "bigquery" %}My_Integer_Col{% else %}"My_Integer_Col"{% endif %},
        {% if target.type == "bigquery" %}My_Bool_Col{% else %}"My_Bool_Col"{% endif %}

    from source

)

select * from renamed
{% endset %}

{{ assert_equal (actual_base_model | trim, expected_base_model | trim) }}
