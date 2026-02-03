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

if [ ! -d "$LEXICON_PATH" ]; then
    echo "::error::Lexicon path does not exist: $LEXICON_PATH"
    exit 1
fi

echo "Checking for breaking changes in: $LEXICON_PATH"
echo "::group::Breaking Changes Check"

HAS_ERRORS="false"

if ! RESULT=$(goat lex breaking --lexicons-dir="$LEXICON_PATH" 2>&1); then
    HAS_ERRORS="true"
fi
echo "$RESULT"

echo "::endgroup::"

# Set outputs
output "result" "$RESULT"
output "has-errors" "$HAS_ERRORS"

if [ "$HAS_ERRORS" = "true" ]; then
    echo "::error::Breaking changes detected"
    exit 1
else
    echo "::notice::No breaking changes detected"
fi
