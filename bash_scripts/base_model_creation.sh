#!/bin/bash

echo "" > models/stg_$1__$2.sql

dbt run-operation codegen.generate_base_model --args '{"source_name": "'$1'", "table_name": "'$2'"}' | tail -n +3 >> models/$1__$2.sql