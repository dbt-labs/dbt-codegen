# dbt-codegen v0.4.0 (unreleased)

## Fixes

## Features

## Other

# dbt-codegen v0.3.2

This is a quality of life release

## Other
* Fix rendering issues on hub.getdbt.com
* Fix integration tests due to python version compatibility

# dbt-codegen v0.3.1
This is a bugfix release

## Fixes
- Use latest version of dbt-utils (0.6.2) to ensure generate_source_yaml works for non-target schemata (#34)

# dbt-codegen v0.3.0
## 🚨  Breaking change
This release requires dbt v0.18.0, and dbt-utils v0.6.1. If you're not ready to upgrade, consider using a previous release of this package.

## Quality of life
- Use dbt v0.18.0 (#31)
- Fix README rendering on hub  (#32 @calvingiles)

# dbt-codegen v0.2.0
## 🚨 Breaking change
The lower bound of `dbt-utils` is now `0.4.0`.

This won't affect most users, since you're likely already using version of dbt-utils higher than this to achieve 0.17.0 compatibility.

## Quality of life:
- Change dbt-utils dependencies to `[>=0.4.0, <0.6.0]` (#29)
- Fix tests (#29)

# dbt-codegen v0.1.0
## 🚨 Breaking change!

This package now requires dbt v0.17.x!

## Features:
* Add `generate_model_yaml` (#18 @jtalmi)


## Under the hood:
* Update to v0.17.0, including `dbt_project.yml` version 2 syntax (#23)
* Add GitHub templates and installation instructions (#23)

## Acknowledgements
@marzaccaro made a PR for `generate_model_yaml`, and, although I had reviewed it, I let the PR go stale and somehow completely forgot about it when merging PR #18 — this is completely my bad! So equal credit to @marzaccaro and @jtalmi for their work :clap:

# dbt-codegen v0.0.4
This is a bugfix release to improve compatibility with Snowflake

# dbt-codegen v0.0.3
Bump utils version range

# dbt-codegen v0.0.2
Small quality of life improvements

# dbt-codegen v0.0.1
Initial release
