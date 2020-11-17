
{% set actual_base_model = codegen.generate_base_model_from_ref(
    ref_name='data__a_relation'
  )
%}

{% set expected_base_seed_model %}
with source as (

    select * from {%raw%}{{ ref('data__a_relation') }}{%endraw%}

),

renamed as (

    select
        col_a,
        col_b

    from source

)

select * from renamed
{% endset %}

{{ assert_equal (actual_base_model | trim, expected_base_seed_model | trim) }}
