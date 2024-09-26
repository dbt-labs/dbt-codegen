## Table of Contents

1. [Overview](#overview)
   1. [Prerequisites](#prerequisites)
   2. [Introduction](#introduction)
2. [Setup](#setup)
   1. [Configure credentials](#configure-credentials)
   2. [Setup Postgres or other database targets](#setup-postgres-or-other-database-targets)
   3. [Set up virtual environment](#set-up-virtual-environment)
   4. [Install dependencies](#install-dependencies)
3. [Write or modify an integration test](#write-or-modify-an-integration-test)
   1. [Run the integration tests](#run-the-integration-tests)
   2. [Creating a new integration test](#creating-a-new-integration-test)
4. [Implement the functionality](#implement-the-functionality)
5. [Commit your changes and open a pull request](#commit-your-changes-and-open-a-pull-request)

## Overview

### Prerequisites

- [python3](https://www.python.org/)
- [make](<https://en.wikipedia.org/wiki/Make_(software)>) (Optional, but recommended for better development experience)[^1]
- [Docker](https://www.docker.com/) (Optional, but recommended for using Postgres as your target database easily)[^2]

### Introduction

Packages in dbt are actually dbt projects themselves, you write SQL and Jinja, sometimes in macros, to add new functionality or models to another dbt project. As SQL and Jinja rely on input data, it's essential to have a functioning project to be able to test that the code works as expected. Constantly running the code, loading data, running bits and pieces, and hoping for the best is not a good development flow though, nor is it a reliable way to ensure that everything works. This is why our dbt packages have integration tests. These tests run all of the data loading, model building, and tests that are defined in the package inside testing environments, and check that the results are as expected.

If you add or modify functionality in any codegen macros, there should be corresponding changes to the integration tests. This README will walk you through this process. Let's outline the basic steps first:

1. Set up your environment (credentials, virtual environment, dependencies, test database(s))
2. Write or modify an integration test (you should expect this to fail as you haven't implemented the functionality yet!)
3. Implement the functionality in the new or modified macro, and run the tests to get them to pass.
4. Commit your changes and open a pull request.

## Setup

### Configure credentials

You'll need to set environment variables with the credentials to access your target database. If you're using the recommended local development path of Postgres in Docker, these values are already filled in as they are generic. For the cloud warehouses listed, you'll need real credentials. You probably want to ensure you're building into a testing schema as well to keep the output of this codegen separate from any production data. We run against all the warehouses listed in the CI (implmented via CircleCI) when you open a PR, so feel free to test against Postgres while developing, and we'll ensure the code works against all the other targets.

You can set these env vars in a couple ways:

- **Temporary**: Set these environment variables in your shell before running the tests. This is the easiest way to get started, but you'll have to set them every time you open a new terminal.
- **Reusable**: If you anticipate developing for multiple sessions, set these environment variables in your shell profile (like `~/.bashrc` or `~/.zshrc`). This way, you won't have to set them every time you open a new terminal.

The environment variables you'll need to set for each adapter when running tests with the bash script:

```bash
# Postgres — these are the defaults for the Docker container so actually have values
export POSTGRES_TEST_HOST=localhost
export POSTGRES_TEST_USER=root
export POSTGRES_TEST_PASS=''
export POSTGRES_TEST_PORT=5432
export POSTGRES_TEST_DBNAME=circle_test

# BigQuery
export BIGQUERY_SERVICE_KEY_PATH=
export BIGQUERY_TEST_DATABASE=

# Redshift
export REDSHIFT_TEST_HOST=
export REDSHIFT_TEST_USER=
export REDSHIFT_TEST_PASS=
export REDSHIFT_TEST_DBNAME=
export REDSHIFT_TEST_PORT=

# Snowflake
export SNOWFLAKE_TEST_ACCOUNT=
export SNOWFLAKE_TEST_USER=
export SNOWFLAKE_TEST_PASSWORD=
export SNOWFLAKE_TEST_ROLE=
export SNOWFLAKE_TEST_DATABASE=
export SNOWFLAKE_TEST_WAREHOUSE=
```

The environment variables you'll need to set for each adapter when running tests with tox can be found in [integration_tests/.env/](integration_tests/.env/).

### Setup Postgres or other database targets

As mentioned, you'll need a target database to run the integration tests and develop against. You can use a cloud warehouse, but the easiest and free way to work is to use Postgres locally. We include a `docker-compose.yml` file that will spin up a Postgres container for you to make this easy.

To run the Postgres container, just run:

```shell
make setup-db
```

Or, alternatively:

```shell
docker-compose up --detach postgres
```

> [!NOTE]
> `make` is a venerable build tool that is included in most Unix-like operating systems. It's not strictly necessary to use `make` to develop on this project, but there are several `make` commands that wrap more complex commands and make development easier. If you don't have `make` installed or don't want to use it, you can just run the commands in the `Makefile` directly. All the examples will show both options.

### Set up virtual environment

We strongly recommend using virtual environments when developing code in `dbt-codegen`. We recommend creating this virtual environment in the root of the `dbt-codegen` repository. To create a new virtual environment, run:

```shell
python3 -m venv .venv
source .venv/bin/activate
```

This will create and activate a new Python virtual environment.

### Install dependencies

First make sure that you set up your virtual environment as described above. Also ensure you have the latest version of pip and setuptools installed:

```
python3 -m pip install --upgrade pip setuptools
```

Next, install `dbt-core` (and its dependencies) with:

```shell
make dev target=[postgres|redshift|...]
# or
python3 -m pip install --pre dbt-core dbt-[postgres|redshift|...]
```

Or more specific:

```shell
make dev target=postgres
# or
python3 -m pip install --pre dbt-core dbt-postgres
```

> [!NOTE]
> The `--pre` flag tells pip to install the latest pre-release version of whatever you pass to install. This ensures you're always using the latest version of dbt, so if your code interacts with dbt in a way that causes issues or test failures, we'll know about it ahead of a release.

Make sure to reload your virtual environment after installing the dependencies:

```shell
source .venv/bin/activate
```

## Write or modify an integration test

Run all the tests _before_ you start developing to make sure everything is working as expected before you start making changes. Nothing is worse than spending a ton of time troubleshooting a failing test, only to realize it was failing before you touched anything. This will also ensure that you have the correct environment variables set up and that your database is running.

### Run the Circle CI integration tests

To run all the integration tests on your local machine like they will get run in CI:

```shell
make test target=[postgres|redshift|...]
# or
./run_test.sh [postgres|redshift|...]
```

Or more specific:

```shell
make test target=postgres
# or
./run_test.sh postgres
```

### Run the tox Supported Tests

To run all the integration tests on your local machine like they will get run in the CI (using GitHub workflows with tox):

```shell
make test_tox target=postgres
```

### Creating a new integration test

Adding integration tests for new functionality typically involves making one or more of the following:

- a new seed file of fixture data
- a new model file to test against
- a new test to assert anticipated behaviour

Once you've added and/or edited the necessary files, assuming you are in the sub-project in the `integration_tests` folder, you should be able to run and test your new additions specifically by running:

```shell
dbt deps --target {your_target}
dbt build --target {your_target} --select +{your_selection_criteria}
```

The `dbt build` command will handle seeding, running, and testing the selection in a single command. The `+` operator in the `--select` flag indicates we also want to build everything that this selection depends on.

Or simply `make dev target={your_target}` and then `make test target={your_target}` if you're okay with running the entire project and all tests.

Remember, typically you'll want to create a failing test _first_, then implement the functionality to make it pass. This is called "test-driven development" (TDD) and it's a great way to ensure that your code really does what you expect it to. For example, let's imagine you wrote a test expecting it to fail, but it passed before you even implemented your logic! That would mean the test is not actually testing what you want, and you'd need to re-evaluate your assumptions. That's something you want to catch early in the development process, and what TDD is all about. So, expect this run of tests after you add your new logic to fail.

## Implement the functionality

Okay finally, this is the fun part! You can now implement the functionality in the macro you're working on.The development flow should be something like:

1. You've got a failing test, so you know what you need to implement.
2. Implement some logic in the macro you're working on.
3. Run the relevant tests to see if they pass.
4. Repeat until the tests pass.
5. Run the full test suite to ensure you didn't break anything else by accident.

## Commit your changes and open a pull request

Once your tests are passing and you're happy with the code, you'll want to commit it and open a new PR on GitHub. Don't forget to run the full test suite against your target database before you open a PR to make sure you didn't accidentally break any existing functionality. When you open a PR, CircleCI will run the same test suite against all the database targets. If they're passing, we'll triage and review the code as soon as we can! Thank you for contributing to dbt-codegen!

[^1]: If you're on a Mac, `make` is probably best installed with the XCode Command Line Tools, or you can install `make` via Homebrew with `brew install cmake`. If you're on Windows, you can either use the Windows Subsystem for Linux (WSL) or use `scoop` or `chocolatey` to install `make`. If you're on Linux, you probably already have `make` installed.
[^2]: Specific instructions on installing and getting started with Docker for your OS can be found [here](https://docs.docker.com/get-docker/).
