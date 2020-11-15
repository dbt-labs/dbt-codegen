{% macro generate_base_seed_model(seed_name) %}

{%- set columns = adapter.get_columns_in_relation(ref(seed_name)) -%}
{% set column_names=columns | map(attribute='name') %}
{% set base_model_sql %}
with source as (

    select * from {% raw %}{{ ref({% endraw %}'{{ seed_name }}'{% raw %}) }}{% endraw %}

),

renamed as (

    select
        {%- for column in column_names %}
        {{ column | lower }}{{"," if not loop.last}}
        {%- endfor %}

    from source

)

select * from renamed
{% endset %}

{% if execute %}

{{ log(base_model_sql, info=True) }}
{% do return(base_model_sql) %}

{% endif %}
{% endmacro %}