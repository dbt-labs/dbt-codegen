{% if target.type == "bigquery" %}

    {#--- This exists to test the BigQuery-specific behavior requested in #190 -#}
    select 
        [1,2,3,4] as repeated_int,
        [
            STRUCT(1 as int_field),
            STRUCT(2 as int_field)
        ] as repeated_struct

{% else %}
    select 1 as int_field
{% endif %}
