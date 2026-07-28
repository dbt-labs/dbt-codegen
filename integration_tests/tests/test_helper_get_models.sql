-- depends_on: {{ ref('model_data_a') }}
-- depends_on: {{ ref('model_incremental') }}
-- depends_on: {{ ref('model_struct') }}
-- depends_on: {{ ref('model_without_import_ctes') }}
-- depends_on: {{ ref('model_without_any_ctes') }}

{% if execute %}
{% set uppercase_model_names = codegen.get_models(prefix='Model_') %}
{% set lowercase_model_names = codegen.get_models(prefix='model_') %}

{% set all_models = uppercase_model_names + lowercase_model_names %}
{% set actual_list = all_models | sort %}
{% endif %}

{% set expected_list = ['model_data_a', 'model_from_source', 'Model_from_source_case_sensitive', 'model_incremental', 'model_repeated', 'model_struct', 'model_without_any_ctes', 'model_without_import_ctes'] %}

{{ assert_equal (actual_list, expected_list) }}
