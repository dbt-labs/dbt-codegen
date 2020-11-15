
{% set actual_base_model = codegen.generate_base_seed_model(
    seed_name='data__a_relation'
  )
%}

{% set expected_base_seed_model %}
with source as (

    select * from {% raw %}{{ ref({% endraw %}'{{ seed_name }}'{% raw %}) }}{% endraw %}

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
