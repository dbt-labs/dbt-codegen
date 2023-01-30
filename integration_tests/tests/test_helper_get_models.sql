-- depends_on: {{ ref('model_data_a') }}
-- depends_on: {{ ref('model_struct') }}
-- depends_on: {{ ref('model_without_import_ctes') }}
-- depends_on: {{ ref('model_without_any_ctes') }}

{% if execute %}
{% set actual_list = codegen.get_models(prefix='model_') %}
{% endif %}

{% set expected_list %}
['model_without_import_ctes', 'model_without_any_ctes', 'model_struct', 'model_data_a']
{% endset %}

{{ assert_equal (actual_list | trim, expected_list | trim) }}
