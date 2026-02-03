#!/bin/bash
set -e

# Function to output to GitHub Actions (handles multiline values)
output() {
    local name="$1"
    local value="$2"
    { echo "${name}<<EOF"; echo "$value"; echo "EOF"; } >> "$GITHUB_OUTPUT"
}

echo "Using goat version: $(goat -v)"

LEXICON_PATH="${INPUT_LEXICON_PATH:-.}"
UPDATE="${INPUT_UPDATE:-false}"
SKIP_DNS_CHECK="${INPUT_SKIP_DNS_CHECK:-false}"

if [ ! -d "$LEXICON_PATH" ]; then
    echo "::error::Lexicon path does not exist: $LEXICON_PATH"
    exit 1
fi

if [ -z "$GOAT_USERNAME" ]; then
    echo "::error::Username is required for publish"
    exit 1
fi

if [ -z "$GOAT_PASSWORD" ]; then
    echo "::error::Password is required for publish"
    exit 1
fi

# Mask password in logs
echo "::add-mask::$GOAT_PASSWORD"

echo "Publishing lexicons from: $LEXICON_PATH"
echo "::group::Publish Results"

HAS_ERRORS="false"

# Build command arguments
ARGS="--lexicons-dir=$LEXICON_PATH"
if [ "$UPDATE" = "true" ]; then
    ARGS="$ARGS --update"
fi
if [ "$SKIP_DNS_CHECK" = "true" ]; then
    ARGS="$ARGS --skip-dns-check"
fi

# shellcheck disable=SC2086
if ! RESULT=$(goat lex publish $ARGS 2>&1); then
    HAS_ERRORS="true"
fi
echo "$RESULT"

echo "::endgroup::"

# Set outputs
output "result" "$RESULT"
output "has-errors" "$HAS_ERRORS"

if [ "$HAS_ERRORS" = "true" ]; then
    echo "::error::Publishing failed"
    exit 1
else
    echo "::notice::Publishing completed successfully"
fi
