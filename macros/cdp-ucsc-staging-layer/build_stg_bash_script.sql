{% macro build_stg_bash_script(source_name) -%}

/* The macro is simply parsing the sources file and making a determination if the table is defined as 
   effective dated and if so building the appropriate output string that is used to create the bash script
   to generate all of the staging models defined in the sources.yml file.

example:
  dbt run-operation --quiet build_stg_bash_script  --args '{"source_name": "fis"}' > utilities/bash_scripts/gen_fis_stg_models.shl

sample output
  dbt run-operation --quiet stage_banner_tables --args '{"source_name": "fis", "table_name": "ftvfsyr", "alphabetize": true}'
  dbt run-operation --quiet stage_banner_eff_date_tables --args '{"source_name": "fis", "table_name": "ftvftyp", "partition_columns": ['ftvftyp_ftyp_code'],"alphabetize": true}'

*/

{% set out_string = '"alphabetize"'": true}' > models/staging/" ~ source_name ~ "/stg_" ~ source_name ~ "__" %}

{% if execute %}

{% for node in graph.sources.values() | selectattr("source_name", "equalto", source_name) %}
    {% set arg_string = "'{"'"source_name"'": " ~ '"' ~ source_name ~ '", ' ""'"table_name"'": " ~ '"' ~ node.name ~ '", ' %}

    {# If effective_type is not specified, then default to using stg_non_eff. #}
    {% if not node.meta.effective_type %}
        {% set run_string = "dbt run-operation --quiet stg_non_eff --args "%}

    {# If effective_type is specified, then use that. #}
    {% else %}
        {% set run_string = "dbt run-operation --quiet " ~ node.meta.effective_type ~ " --args "%}
    {% endif %}

    {% do print( run_string ~ arg_string ~ out_string ~ node.name ~ ".sql") %}

{% endfor %}
{% endif %}

{%- endmacro %}


