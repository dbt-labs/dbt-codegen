{% if target.type == "bigquery" %}

    {#--- This exists to test the BigQuery-specific behavior reqeusted in #27 -#}
    select
        STRUCT(
            source,
            medium,
            source_medium
        ) as analytics,
        col_x
    from {{ ref('data__campaign_analytics') }}

{% else %}

    {#--- This enables mimicking the BigQuery behavior for other adapters -#}
    select
        analytics,
        source,
        medium,
        source_medium,
        col_x
    from {{ ref('data__campaign_analytics') }}

{% endif %}
