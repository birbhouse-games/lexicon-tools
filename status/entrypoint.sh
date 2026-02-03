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

echo "Checking lexicon status against network for: $LEXICON_PATH"
echo "::group::Status Check Results"

HAS_CHANGES="false"

RESULT=$(goat lex status --lexicons-dir="$LEXICON_PATH" 2>&1) || true
echo "$RESULT"

# Check for status indicators showing changes
if echo "$RESULT" | grep -qE "🟡|🔴|🟠|🟣"; then
    HAS_CHANGES="true"
fi

echo "::endgroup::"

# Set outputs
output "result" "$RESULT"
output "has-changes" "$HAS_CHANGES"

if [ "$HAS_CHANGES" = "true" ]; then
    echo "::notice::Lexicon status check found differences from network"
else
    echo "::notice::Lexicons are in sync with network"
fi
