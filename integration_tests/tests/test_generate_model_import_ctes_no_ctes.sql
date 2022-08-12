{% set actual_model_with_import_ctes = codegen.generate_model_import_ctes(
    model_name = 'model_without_any_ctes'
  )
%}

{% set expected_model_with_import_ctes %}
with model_without_import_ctes as (

    select * from {% raw %}{{ ref('model_without_import_ctes') }}{% endraw %}
  
)
select *, 2 as col2
from model_without_import_ctes
where id = 1
{% endset %}

{{ assert_equal (actual_model_with_import_ctes | trim, expected_model_with_import_ctes | trim) }}