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


# Run tests. Args are passed to 'pytest' unchanged
test *args:
    uv run pytest {{args}}
