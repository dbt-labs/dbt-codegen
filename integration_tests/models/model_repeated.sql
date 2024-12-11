{% if target.type == "bigquery" %}

    {#--- This exists to test the BigQuery-specific behavior requested in #190 -#}
select
  [1, 2] AS repeated_int,
  [
    STRUCT(1 as nested_int_field, [STRUCT("a" as string_field)] as nested_repeated_struct),
    STRUCT(2 AS nested_int_field, [STRUCT("a" as string_field)] as nested_repeated_struct)
  ] as repeated_struct

{% else %}
    select 1 as int_field
{% endif %}
