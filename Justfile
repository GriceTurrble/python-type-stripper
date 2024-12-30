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
_test version *args:
    uv run --python {{version}} pytest {{args}}

# Run tests with pytest 'args'
[group("testing")]
test *args:
    @just _test 3.13 {{args}}

# Run tests in sequence for all python versions available. Note, coverage reporting is disabled
[group("testing")]
test-all-versions *args:
    @echo "{{ BG_GREEN }}>> Testing on 3.9...{{ NORMAL }}"
    @just _test 3.9 {{args}} --no-cov
    @echo "{{ BG_GREEN }}>> Testing on 3.10...{{ NORMAL }}"
    @just _test 3.10 {{args}} --no-cov
    @echo "{{ BG_GREEN }}>> Testing on 3.11...{{ NORMAL }}"
    @just _test 3.11 {{args}} --no-cov
    @echo "{{ BG_GREEN }}>> Testing on 3.12...{{ NORMAL }}"
    @just _test 3.12 {{args}} --no-cov
    @echo "{{ BG_GREEN }}>> Testing on 3.13...{{ NORMAL }}"
    @just _test 3.13 {{args}} --no-cov
    @echo "{{ BG_GREEN }}>> SUCCESS: All tests passing. :){{ NORMAL }}"

# The result should be `\\[ \\]`, but we need to escape those slashes again here to make it work:
GREP_TARGET := "\\\\[gone\\\\]"

# Switches to `main` branch, then prunes local branches deleted from remote.
[group("git")]
prune_dead_branches:
    @echo "{{ BG_GREEN }}>> 'Removing dead branches...{{ NORMAL }}"
    @git switch main
    @git fetch --prune
    @git branch -v | grep "{{ GREP_TARGET }}" | awk '{print $1}' | xargs -I{} git branch -D {}
