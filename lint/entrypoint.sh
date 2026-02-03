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
JSON_OUTPUT="${INPUT_JSON_OUTPUT:-false}"
FAILURE_THRESHOLD="${INPUT_FAILURE_THRESHOLD:-error}"

if [ ! -d "$LEXICON_PATH" ]; then
    echo "::error::Lexicon path does not exist: $LEXICON_PATH"
    exit 1
fi

echo "Linting lexicons from: $LEXICON_PATH"
echo "::group::Lint Results"

HAS_ERRORS="false"
HAS_WARNINGS="false"

if [ "$JSON_OUTPUT" = "true" ]; then
    RESULT=$(goat lex lint --lexicons-dir="$LEXICON_PATH" --json 2>&1 | jq --slurp '.' || echo "[]")
    echo "$RESULT" | jq '.'
    HAS_ERRORS=$(echo "$RESULT" | jq 'any(."lint-level" == "error")' 2>/dev/null || echo "false")
    HAS_WARNINGS=$(echo "$RESULT" | jq 'any(."lint-level" == "warning")' 2>/dev/null || echo "false")
else
    RESULT=$(goat lex lint --lexicons-dir="$LEXICON_PATH" 2>&1) || true
    echo "$RESULT"
    if echo "$RESULT" | grep -q "🟡"; then HAS_WARNINGS="true"; fi
    if echo "$RESULT" | grep -q "🔴"; then HAS_ERRORS="true"; fi
fi

echo "::endgroup::"

# Set outputs
output "result" "$RESULT"
output "has-errors" "$HAS_ERRORS"
output "has-warnings" "$HAS_WARNINGS"

# Determine exit behavior based on failure-threshold
case "$FAILURE_THRESHOLD" in
    none)
        if [ "$HAS_ERRORS" = "true" ]; then
            echo "::warning::Lint found errors (failure-threshold: none)"
        elif [ "$HAS_WARNINGS" = "true" ]; then
            echo "::warning::Lint found warnings"
        else
            echo "::notice::Lint passed"
        fi
        ;;
    warning)
        if [ "$HAS_ERRORS" = "true" ]; then
            echo "::error::Lint found errors"
            exit 1
        elif [ "$HAS_WARNINGS" = "true" ]; then
            echo "::error::Lint found warnings (failure-threshold: warning)"
            exit 1
        else
            echo "::notice::Lint passed"
        fi
        ;;
    *)
        if [ "$HAS_ERRORS" = "true" ]; then
            echo "::error::Lint found errors"
            exit 1
        elif [ "$HAS_WARNINGS" = "true" ]; then
            echo "::warning::Lint found warnings"
        else
            echo "::notice::Lint passed"
        fi
        ;;
esac
