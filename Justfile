# Just tools to work on the project.
# https://just.systems/

# Show these help docs
help:
    @just --list --unsorted --justfile {{ source_file() }}


# Setup dev environment
[group("devtools")]
bootstrap:
    pre-commit install
    uv sync


# Lint all project files using 'pre-commit run <hook_id>'. By default, runs all hooks.
[group("devtools")]
lint hook_id="":
    pre-commit run {{hook_id}} --all-files


# Run tests on Python 'version' with pytest 'args'
[group("testing")]
test-on version *args:
    @echo "{{ GREEN }}>> Testing on {{ version }}...{{ NORMAL }}"
    uv run --python {{ version }} pytest {{ args }}


# Run tests with pytest 'args' on latest Python
[group("testing")]
test *args:
    @just test-on 3.13 {{ args }}


# Run tests in sequence for all Python versions available. Note, coverage reporting is disabled
[group("testing")]
test-all *args:
    @just test-on 3.9 {{ args }} --no-cov
    @just test-on 3.10 {{ args }} --no-cov
    @just test-on 3.11 {{ args }} --no-cov
    @just test-on 3.12 {{ args }} --no-cov
    @just test-on 3.13 {{ args }} --no-cov
    @echo "{{ GREEN }}>> SUCCESS: All tests passing. :){{ NORMAL }}"


# The result should be `\\[ \\]`, but we need to escape those slashes again here to make it work:
GREP_TARGET := "\\\\[gone\\\\]"

# Prunes local branches deleted from remote.
[group("git")]
prune-dead-branches:
    @echo "{{ GREEN }}>> Removing dead branches...{{ NORMAL }}"
    @git fetch --prune
    @git branch -v | grep "{{ GREP_TARGET }}" | awk '{print $1}' | xargs -I{} git branch -D {}

alias prune := prune-dead-branches

[group("release")]
draft-release tag:
    gh release create v{{ tag }} -d --generate-notes
