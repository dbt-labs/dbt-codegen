#!/bin/bash

echo `pwd`
cd integration_tests
cp ci/sample.profiles.yml profiles.yml

export POSTGRES_HOST=localhost
export POSTGRES_USER=root
export DBT_ENV_SECRET_POSTGRES_PASS=password
export POSTGRES_PORT=5432
export POSTGRES_DATABASE=codegen_test
export POSTGRES_SCHEMA=codegen_integration_tests_postgres

# Create database if it doesn't exist
PGPASSWORD=$DBT_ENV_SECRET_POSTGRES_PASS psql -h $POSTGRES_HOST -U $POSTGRES_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DATABASE'" | grep -q 1 || \
PGPASSWORD=$DBT_ENV_SECRET_POSTGRES_PASS psql -h $POSTGRES_HOST -U $POSTGRES_USER -d postgres -c "CREATE DATABASE $POSTGRES_DATABASE"

dbt --warn-error clean --target $1 || exit 1
dbt --warn-error deps --target $1 || exit 1
dbt --warn-error run-operation create_source_table --target $1 || exit 1
dbt --warn-error seed --target $1 --full-refresh || exit 1
dbt --warn-error run --target $1 || exit 1
dbt --warn-error test --target $1 || exit 1
