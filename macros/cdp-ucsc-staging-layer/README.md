# CDP's Staging Layer Macros
For the core domain projects, the staging layer has been generated using the custom macros contained in this directory. Source tables are grouped into non-effective and effective dated tables. Where effective dated tables are further categorized into different types.

## Non-effective dated tables
All non-effective dates tables are generated with the `stg_non_eff` macro.

## Effective dated tables
Effective dated tables are categorized into the following types:
- Type 1. The effective date column is a date type and the table is **not** effective sequenced.
- Type 2. The effective date column is a date type and the table **is** effective sequenced.
- Type 3. The effective date column is a timestamp and the table is **not** effective sequenced.
  - Type 3 tables can be turned into type 1 or type 2 tables.
- Type 4. The effective date column is a timestamp and the table **is** effective sequenced.
  - Type 4 tables can be turned into type 2 tables.

| Use Case | Macro |
|---|---|
| If the source table is a type 1 table, then use this macro to generate the staging model. | stg_eff_type_1 |
| If the source table is a type 2 table, then use this macro to generate the staging model. | stg_eff_type_2 |
| If the source table is a type 3 table and cannot have multiple transactions in a single day, then use this macro to generate the staging model. The macro will automatically convert the effective date column into a date type. | stg_eff_type_1 |
| If the source table is a type 3 table and can have multiple transactions in a single day, then use this macro to generate the staging model. The macro will automatically convert the effective date column into a date type. | stg_eff_type_3_to_type_2 |
| If the source table is a type 4 table, then use this macro to generate the staging model. The macro will automatically convert the effective date column into a date type. | stg_eff_type_2 |

## Source.yml
A key feature of the macros is that they are able to read and implement information from the source.yml in the generated staging models. The following information can or needs to be declared in the `source.yml`.

```yaml
version:
sources:
    - name: source_name
      meta:
        soft_delete_columns:
      tables:
        - name: table_name
          meta:
            effective_type:
            effective_date_col:
            effective_sequence_col:
            effective_sequence_order:
            partition_columns:
            columns:
              - name: column_a
                meta:
                  casted_as: data_type
                  renamed_as: new_name
```

| Resource level | Key | Value(s) | Description |
|---|---|---|---|
| sources.meta | soft_delete_columns | ["col_a is condition", "col_b is condition"] | Not required.<br>Implements the specified conditions on the `source` CTE's `where` clause.<br><br>EX: ["_fivetran_deleted != true", "dml_ind != 'D'"] |
| sources.tables.meta | effective_type | stg_non_eff,<br>stg_eff_type_1,<br>stg_eff_type_2,<br>or stg_eff_type_3_to_type_2 | Identifies which staging macro should be used.<br>If not specified, then defaults to `stg_non_eff`.<br>Case sensitive. Must match macro name exactly. |
| sources.tables.meta | effective_date_col | column_name | Required for: `stg_eff_type_1`, `stg_eff_type_2`, `stg_eff_type_3_to_type_2`<br>This column identifies which column is tracking the transaction date.<br>This column will always be automatically casted as a date in the macro.<br>If this column has been renamed, use the original name. |
| sources.tables.meta | effective_sequence_col | column_name | Required for: `stg_eff_type_2`<br>This column identifies which column is tracking the transaction sequence for a single day.<br>If this column has been renamed, use the original name. |
| sources.tables.meta | effective_sequence_order | asc or desc | Required for: `stg_eff_type_2`<br>If the greatest effective sequence reflects the last transaction of the day, then use asc.<br>If the smallest effective sequence reflects the last transaction of the day, then use desc.<br>Case sensitive. Must be in all lower case. |
| sources.tables.meta | partition_columns | ["col_a", "col_b", ...] | Required for: `stg_eff_type_1`, `stg_eff_type_2`, `stg_eff_type_3_to_type_2`<br>This column identifies what columns the table should be partitioned by.<br>If a column has been renamed, use the original name. |
| sources.tables.columns.meta | casted_as | data_type | Optional.<br>If a column should be recasted, then declare the data type is should be casted as. |
| sources.tables.columns.meta | renamed_as | new_name | Optional.<br>If a column should be renamed, then declare the new name it should be renamed to. |
