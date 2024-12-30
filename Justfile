# Just tools to work on the project.
# https://just.systems/

# Show these help docs
help:
    @just --list --unsorted --justfile {{ source_file() }}


# Setup dev environment
bootstrap:
    pre-commit install
    uv sync


# Lint all project files using 'pre-commit run <hook_id>'. By default, runs all hooks.
lint hook_id="":
    pre-commit run {{hook_id}} --all-files


# Run tests on Python 'version' with pytest 'args'
_test version *args:
    uv run --python {{version}} pytest {{args}}

# Run tests with pytest 'args'
test *args:
    @just _test 3.13 {{args}}

# Run tests in sequence for all python versions available. Note, coverage reporting is disabled
test-all-versions *args:
    @echo ">>\n>> Testing on 3.9...\n>>"
    @just _test 3.9 {{args}} --no-cov
    @echo ">>\n>> Testing on 3.10...\n>>"
    @just _test 3.10 {{args}} --no-cov
    @echo ">>\n>> Testing on 3.11...\n>>"
    @just _test 3.11 {{args}} --no-cov
    @echo ">>\n>> Testing on 3.12...\n>>"
    @just _test 3.12 {{args}} --no-cov
    @echo ">>\n>> Testing on 3.13...\n>>"
    @just _test 3.13 {{args}} --no-cov
    @echo ">> SUCCESS: All tests passing. :)"
