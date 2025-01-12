# Just tools to work on the project.
# https://just.systems/

# Show these help docs
@help:
    just --list --unsorted --justfile {{ source_file() }}

# Sync uv dependencies for all groups
[group("devtools")]
sync:
    uv sync --all-groups

# Setup dev environment
[group("devtools")]
bootstrap:
    pre-commit install
    just sync


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
@test *args:
    just test-on 3.13 {{ args }}


# Run tests in sequence for all Python versions available. Note, coverage reporting is disabled
[group("testing")]
@test-all *args:
    just test-on 3.9 {{ args }} --no-cov
    just test-on 3.10 {{ args }} --no-cov
    just test-on 3.11 {{ args }} --no-cov
    just test-on 3.12 {{ args }} --no-cov
    just test-on 3.13 {{ args }} --no-cov
    echo "{{ GREEN }}>> SUCCESS: All tests passing. :){{ NORMAL }}"


# The result should be `\\[ \\]`, but we need to escape those slashes again here to make it work:
GONE_GREP_TARGET := "\\\\[gone\\\\]"

# Prunes local branches deleted from remote.
[group("git")]
prune-dead-branches:
    @echo "{{ GREEN }}>> Removing dead branches...{{ NORMAL }}"
    git fetch --prune
    git branch -v | grep "{{ GONE_GREP_TARGET }}" | awk '{print $1}' | xargs -I{} git branch -D {}


# Remove all local tags and re-fetch tags from the remote. Tags removed from remote will now be gone.
[group("git")]
prune-tags:
    @echo "{{ GREEN }}>> Cleaning up tags not present on remote...{{ NORMAL }}"
    git tag -l | xargs git tag -d
    git fetch --tags

# Run all git "prune-" commands above
[group("git")]
prune: prune-dead-branches prune-tags

# # Grabs the latest release name out of GitHub releases.
# # Note the leading 'v' character will be removed.
# LATEST_RELEASE := ```
#     gh release list \
#         --exclude-drafts \
#         --exclude-pre-releases \
#         --limit 1 \
#         --json name \
#         --jq ".[0].name" \
#     | sed s/^v//
# ```
# Extract project version from the init file.
PROJECT_VERSION := `cat src/type_stripper/__init__.py  | grep "^__version__" | sed -rn 's|^[^=]*= "(.*)"|\1|p'`

[no-exit-message]
@_validate_unique_release:
    EXISTING_RELEASE_URL=`gh release view v{{ PROJECT_VERSION }} --json url --jq ".url" 2> /dev/null || echo "not_found"`; \
    if [ "${EXISTING_RELEASE_URL}" != "not_found" ]; \
    then \
        RELEASE_URL=`gh release view v{{ PROJECT_VERSION }} --json url --jq ".url"`; \
        echo "{{ style('error') }}ERROR: cannot draft release v{{ PROJECT_VERSION }} because one already exists:"; \
        echo "  ${EXISTING_RELEASE_URL}{{ NORMAL }}"; \
        exit 1; \
    fi

# Draft a new release on GitHub matching the version from pyproject.toml
[group("releases")]
@draft-release: _validate_unique_release
    just _draft_release

[confirm(">> You are about to draft a new GitHub release. Are you sure? [y/N]")]
_draft-release:
    LATEST_RELEASE=`gh release list \
        --exclude-drafts \
        --exclude-pre-releases \
        --limit 1 \
        --json name \
        --jq ".[0].name" \
        | sed s/^v//` \
    && gh release create \
        v{{ PROJECT_VERSION }} \
        --generate-notes \
        --notes-start-tag v$LATEST_RELEASE \
        --draft

[group("releases")]
@release-diff tag="":
    git fetch --prune
    if [ "{{ tag }}" == "" ]; then \
        LATEST_TAG=`gh release list \
            --exclude-drafts \
            --exclude-pre-releases \
            --limit 1 \
            --json name \
            --jq ".[0].name"`; \
    else \
        LATEST_TAG="v{{ tag }}"; \
    fi; \
    git log \
        --pretty=format:"* %Cgreen%h%Creset %s" \
        ${LATEST_TAG}..HEAD
