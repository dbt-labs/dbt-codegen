{% macro generate_base_model_from_ref(ref_name) %}

{%- set columns = adapter.get_columns_in_relation(ref(ref_name)) -%}
{% set column_names=columns | map(attribute='name') %}
{% set base_model_sql %}
with source as (

    select * from {% raw %}{{ ref({% endraw %}'{{ ref_name }}'{% raw %}) }}{% endraw %}

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