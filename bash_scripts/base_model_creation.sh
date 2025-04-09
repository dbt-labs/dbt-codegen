#!/bin/bash

# Check if at least two arguments are provided (source_name and at least one table_name)
if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <source_name> <table_name1> [table_name2 ... table_nameN]"
  exit 1
fi

SOURCE_NAME=$1
shift # Shift to leave only table names in "$@"

for TABLE_NAME in "$@"; do
  dbt --quiet run-operation codegen.generate_base_model --args '{"source_name": "'$SOURCE_NAME'", "table_name": "'$TABLE_NAME'"}' | tail -n +3 >> models/stg_${SOURCE_NAME}__${TABLE_NAME}.sql
  echo "Generated model for table: $TABLE_NAME"
done
