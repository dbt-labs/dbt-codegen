#!/bin/bash

echo `pwd`
cd integration_tests
cp ci/sample.profiles.yml profiles.yml

dbt --warn-error deps --target $1 || exit 1
dbt --warn-error run-operation create_source_table --target $1 || exit 1
dbt --warn-error seed --target $1 --full-refresh || exit 1
dbt --warn-error run --target $1 || exit 1
dbt --warn-error test --target $1 || exit 1
