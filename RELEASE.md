# dbt-codegen releases

## When do we release?
There's a few scenarios that might prompt a release:

| Scenario                                   | Release type |
|--------------------------------------------|--------------|
| Breaking changes to existing macros        | major        |
| New functionality¹                         | minor        |
| Fixes to existing macros                   | patch        |

## Release process

1. Begin a new release by clicking [here](https://github.com/dbt-labs/dbt-codegen/releases/new)
1. Click "Choose a tag", then paste your version number (with no "v" in the name), then click "Create new tag: x.y.z. on publish"
    - The “Release title” will be identical to the tag name
1. Click the "Generate release notes" button
1. Copy and paste the generated release notes into `CHANGELOG.md`, commit, and merge into the `main` branch
1. Click the "Publish release" button
    - This will automatically create an "Assets" section containing:
        - Source code (zip)
        - Source code (tar.gz)
