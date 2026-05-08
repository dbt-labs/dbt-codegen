select
    *
from {{ source('codegen_integration_tests__data_source_schema', 'codegen_integration_tests__data_source_table_case_sensitive') }}

