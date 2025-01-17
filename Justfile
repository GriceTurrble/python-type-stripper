# Just tools to work on the project.
# https://just.systems/

### START COMMON ###
import? 'common.just'

# Show these help docs
help:
    @just --list --unsorted --justfile {{ source_file() }}

# Pull latest common justfile recipes to local repo
[group("commons")]
sync-commons:
    curl -H 'Cache-Control: no-cache, no-store' \
        https://raw.githubusercontent.com/griceturrble/common-project-files/main/common.just > common.just
### END COMMON ###

# Sync uv dependencies for all groups
[group("devtools")]
sync-uv:
    uv sync --all-groups

# Setup dev environment
[group("devtools")]
bootstrap:
    just sync-commons
    just bootstrap-commons
    just sync-uv


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
        --json tagName \
        --jq ".[0].tagName" \
    && gh release create \
        v{{ PROJECT_VERSION }} \
        --generate-notes \
        --notes-start-tag $LATEST_RELEASE \
        --draft
