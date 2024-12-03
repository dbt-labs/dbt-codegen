# dbt-codegen v0.13.0

## What's Changed

### Features

* Read upstream descriptions from sources by @esegal in https://github.com/dbt-labs/dbt-codegen/pull/154
* Parameters in `generate_source` for case-sensitive identifiers by @pnadolny13 in https://github.com/dbt-labs/dbt-codegen/pull/168

### Fixes

* Escape upstream descriptions in generate_model_yaml by @wircho in https://github.com/dbt-labs/dbt-codegen/pull/159
* Fix quoted identifiers in the `generate_base_model` macro for BigQuery by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/199

### Docs

* fix generate_source example by @yatsky in https://github.com/dbt-labs/dbt-codegen/pull/164
* Improve developer README by @gwenwindflower in https://github.com/dbt-labs/dbt-codegen/pull/163
* Fix bad spacing in dev README by @gwenwindflower in https://github.com/dbt-labs/dbt-codegen/pull/170
* Changelogs for 0.12.0, 0.12.1, and 0.13.0-b1 by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/196

## Under the hood

* Restore CI test for case-sensitive identifiers when generating sources by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/192
* Remove Redshift-specific logic for toggling case-sensitive identifiers by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/208
* Use the `cimg/postgres` Docker image by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/214
* Independent CircleCI workflow job for each tested adapter by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/215
* Simplify environment variables for BigQuery in CircleCI by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/216
* Stop installing prereleases from PyPI in favor of stable releases only by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/220
* Upgrade to Python 3.11 in CircleCI by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/222
* Use dynamic schema names rather than hardcoded ones by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/224
* Add support for postgres testing in GitHub CI via tox by @emmyoop by @emmyoop in https://github.com/dbt-labs/dbt-codegen/pull/181
* Add support for snowflake testing in GitHub CI via tox by @emmyoop in https://github.com/dbt-labs/dbt-codegen/pull/198
* Add support for redshift testing in GitHub CI via tox by @emmyoop in https://github.com/dbt-labs/dbt-codegen/pull/204
* Add support for bigquery testing in GitHub CI via tox by @emmyoop in https://github.com/dbt-labs/dbt-codegen/pull/203

## New Contributors
* @wircho made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/159
* @esegal made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/154
* @yatsky made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/164
* @gwenwindflower made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/163
* @pnadolny13 made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/168
* @emmyoop made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/181

**Full Changelog**: https://github.com/dbt-labs/dbt-codegen/compare/0.12.1...0.13.0

# dbt-codegen v0.13.0-b1

## What's Changed

### Features

* Read upstream descriptions from sources by @esegal in https://github.com/dbt-labs/dbt-codegen/pull/154
* Case sensitive generate source by @pnadolny13 in https://github.com/dbt-labs/dbt-codegen/pull/168

### Fixes

* Escape upstream descriptions in generate_model_yaml by @wircho in https://github.com/dbt-labs/dbt-codegen/pull/159

### Docs

* fix generate_source example by @yatsky in https://github.com/dbt-labs/dbt-codegen/pull/164
* Improve developer README by @gwenwindflower in https://github.com/dbt-labs/dbt-codegen/pull/163
* Fix bad spacing in dev README by @gwenwindflower in https://github.com/dbt-labs/dbt-codegen/pull/170
* Update Changelog by @gwenwindflower in https://github.com/dbt-labs/dbt-codegen/pull/174

## New Contributors

- @wircho made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/159
- @yatsky made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/164
- @pnadolny13 made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/168
- @esegal made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/154
- @gwenwindflower made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/163

**Full Changelog**: https://github.com/dbt-labs/dbt-codegen/compare/0.12.1...v0.13.0-b1

# dbt-codegen v0.12.1

## What's Changed
* Add dispatch to macros by @jeremyyeo in https://github.com/dbt-labs/dbt-codegen/pull/148
* Remove terminal output in the generated file. by @vijmen in https://github.com/dbt-labs/dbt-codegen/pull/149

## New Contributors
* @jeremyyeo made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/148
* @vijmen made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/149

**Full Changelog**: https://github.com/dbt-labs/dbt-codegen/compare/0.12.0...0.12.1

# dbt-codegen v0.12.0

## What's Changed
* Use print for outputting codegen by @JorgenG in https://github.com/dbt-labs/dbt-codegen/pull/86

## New Contributors
* @JorgenG made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/86

**Full Changelog**: https://github.com/dbt-labs/dbt-codegen/compare/0.11.0...0.12.0

# dbt-codegen v0.11.0

## 🚨 Breaking change

`include_data_types` parameter added to `generate_model_yaml` and behavior changed for `generate_source`. Both default to `true`
and are lowercase to align with the dbt style guide. Scale & precision are **not** included. Previous logic for `generate_source` defaulted to `false` and the resulting data types were uppercase and included scale & precision ([#122](https://github.com/dbt-labs/dbt-codegen/pull/122)).

[Dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch) can be used to utilize the column data type formatting of previous versions. Namely, by adding this macro to your project:

```sql
{% macro default__data_type_format_source(column) %}
    {{ return(column.data_type | upper) }}
{% endmacro %}
```

And then adding this within `dbt_project.yml`:

```yaml
dispatch:
  - macro_namespace: codegen
    search_order: ["my_project", "codegen"]
```

## What's Changed

- GitHub Action to add/remove triage labels as-needed by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/133
- GitHub Action to close issues as stale as-needed by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/134
- Update README.md by @cohms in https://github.com/dbt-labs/dbt-codegen/pull/129
- Remove hard-coded values for database and schema by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/139
- Instructions for the release process by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/137
- Add `include_data_types` argument to `generate_model_yaml` macro by @linbug in https://github.com/dbt-labs/dbt-codegen/pull/122

## New Contributors

- @cohms made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/129
- @linbug made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/122

**Full Changelog**: https://github.com/dbt-labs/dbt-codegen/compare/0.10.0...v0.10.0

# dbt-codegen v0.10.0

## What's Changed

- added comments to verbose regex in generate_model_import_ctes by @graciegoheen in https://github.com/dbt-labs/dbt-codegen/pull/93
- Feature/hackathon model generator by @fivetran-joemarkiewicz in https://github.com/dbt-labs/dbt-codegen/pull/83
- Suggestion to include packages.yml example in README.md by @Maayan-s in https://github.com/dbt-labs/dbt-codegen/pull/77
- Add include_data_types flag to generate_source macro by @GSokol in https://github.com/dbt-labs/dbt-codegen/pull/76
- Expected result of nested struct in BigQuery by @dbeatty10 in https://github.com/dbt-labs/dbt-codegen/pull/105
- issue106/get_models helper macro by @erkanncelen in https://github.com/dbt-labs/dbt-codegen/pull/115
- Feat/generate sources add database and schema by @jeremyholtzman in https://github.com/dbt-labs/dbt-codegen/pull/124

## New Contributors

- @fivetran-joemarkiewicz made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/83
- @Maayan-s made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/77
- @GSokol made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/76
- @erkanncelen made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/115
- @jeremyholtzman made their first contribution in https://github.com/dbt-labs/dbt-codegen/pull/124

**Full Changelog**: https://github.com/dbt-labs/dbt-codegen/compare/0.9.0...0.10.0

# dbt-codegen v0.9.0

# dbt-codegen v0.8.1

# dbt-codegen v0.8.0

# Unreleased

## Breaking changes

## New features

## Quality of life

- Now uses `print` instead of `log` to output the generated text into the console. This enables you to invoke dbt with the `--quiet` flag and directly pipe the codegen output into a new file, ending up with valid yaml

## Under the hood

## Contributors:

- [@JorgenG](https://github.com/JorgenG) (#86)

# dbt-codegen v0.7.0

## 🚨 Breaking change

- Add support for including description placeholders for the source and table, which changes the behavior of `generate_source` when `include_descriptions` is set to `True`. Previous logic only created description placeholders for the columns ([#64](https://github.com/dbt-labs/dbt-codegen/issues/64), [#66](https://github.com/dbt-labs/dbt-codegen/pull/66))

## New features

- Add optional `table_names` arg to `generate_source` ([#50](https://github.com/dbt-labs/dbt-codegen/issues/50), [#51](https://github.com/dbt-labs/dbt-codegen/pull/51))
- Add support for importing descriptions from columns with the same names in upstream models. It is available by setting the parameter `upstream_descriptions` to `True` in `generate_model_yaml` ([#61](https://github.com/dbt-labs/dbt-codegen/pull/61))
- Added `case_sensitive_cols` argument to `generate_base_model` macro ([#63](https://github.com/dbt-labs/dbt-codegen/pull/63))
- Add optional `name` arg to `generate_source` ([#64](https://github.com/dbt-labs/dbt-codegen/issues/64), [#66](https://github.com/dbt-labs/dbt-codegen/pull/66))

## Fixes

- `generate_model_yaml` now correctly handles nested `STRUCT` fields in BigQuery ([#27](https://github.com/dbt-labs/dbt-codegen/issues/27), [#54](https://github.com/dbt-labs/dbt-codegen/pull/54))

## Contributors:

- [@rahulj51](https://github.com/rahulj51) (#51)
- [@bodschut](https://github.com/bodschut) (#54)
- [@b-per](https://github.com/b-per) (#61)
- [@graciegoheen](https://github.com/graciegoheen) (#63)
- [@kbrock91](https://github.com/kbrock91) (#66)

# dbt-codegen v0.6.0

This release creates breaking changes to the `generate_source.sql` macro.

## Features

- add optional `table_pattern` argument to `generate_source.sql` macro. Default value is '%' to pull all tables in the raw data schema to preserve existing behavior if the `table_pattern` argument is not specified by the user.

# dbt-codegen v0.5.0

This release supports any version (minor and patch) of v1, which means far less need for compatibility releases in the future.

## Under the hood

- Change `require-dbt-version` to `[">=1.0.0", "<2.0.0"]`
- Bump dbt-utils dependency
- Replace `source-paths` and `data-paths` with `model-paths` and `seed-paths` respectively
- Rename `data` and `analysis` directories to `seeds` and `analyses` respectively
- Replace `dbt_modules` with `dbt_packages` in `clean-targets`

# dbt-codegen v0.4.1

🚨 This is a compatibility release in preparation for `dbt-core` v1.0.0 (🎉). Projects using this version with `dbt-core` v1.0.x can expect to see a deprecation warning. This will be resolved in the next minor release.

# dbt-codegen v0.4.0

## Breaking changes

- Requires `dbt>=0.20.0` and `dbt-utils>=0.7.0`
- Depends on `dbt-labs/dbt_utils` (instead of `fishtown-analytics/dbt_utils`)

## Features

- Add optional `leading_commas` arg to `generate_base_model` (#41 @jaypeedevlin)
- Add optional `include_descriptions` arg to `generate_source` (#40 @djbelknapdbs)

## Fixes

- In the `generate_source` macro, use `dbt_utils.get_relations_by_pattern` instead of `get_relations_by_prefix`, since the latter will be deprecated in the future (#42)

## Under the hood

- Use new adapter.dispatch syntax (#44)

# dbt-codegen v0.3.2

This is a quality of life release

## Other

- Fix rendering issues on hub.getdbt.com
- Fix integration tests due to python version compatibility

# dbt-codegen v0.3.1

This is a bugfix release

## Fixes

- Use latest version of dbt-utils (0.6.2) to ensure generate_source_yaml works for non-target schemata (#34)

# dbt-codegen v0.3.0

## 🚨 Breaking change

This release requires dbt v0.18.0, and dbt-utils v0.6.1. If you're not ready to upgrade, consider using a previous release of this package.

## Quality of life

- Use dbt v0.18.0 (#31)
- Fix README rendering on hub (#32 @calvingiles)

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

- Add `generate_model_yaml` (#18 @jtalmi)

## Under the hood:

- Update to v0.17.0, including `dbt_project.yml` version 2 syntax (#23)
- Add GitHub templates and installation instructions (#23)

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
