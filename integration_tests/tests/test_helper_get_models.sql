-- depends_on: {{ ref('model_data_a') }}
-- depends_on: {{ ref('model_struct') }}
-- depends_on: {{ ref('model_without_import_ctes') }}
-- depends_on: {{ ref('model_without_any_ctes') }}

{% if execute %}
{% set actual_list = codegen.get_models(prefix='model_')|sort %}
{% endif %}

{% set expected_list %}
['model_data_a', 'model_struct', 'model_without_any_ctes', 'model_without_import_ctes']
{% endset %}

{{ assert_equal (actual_list, expected_list) }}
