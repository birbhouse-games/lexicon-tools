#!/bin/bash
set -e

# Function to output to GitHub Actions (handles multiline values)
output() {
    local name="$1"
    local value="$2"

    # Use heredoc syntax for multiline values
    {
        echo "${name}<<EOF"
        echo "$value"
        echo "EOF"
    } >> "$GITHUB_OUTPUT"
}

# Function to set error message and exit
error() {
    echo "::error::$1"
    exit 1
}

# Function to set warning message
warning() {
    echo "::warning::$1"
}

# Function to output notice
notice() {
    echo "::notice::$1"
}

# Print goat version
echo "Using goat version: $(goat -v)"

# Get inputs from environment variables (set by GitHub Actions)
COMMAND="${INPUT_COMMAND:-lint}"
LEXICON_PATH="${INPUT_LEXICON_PATH:-.}"
DID="${INPUT_DID:-}"
JSON_OUTPUT="${INPUT_JSON_OUTPUT:-false}"
FAILURE_THRESHOLD="${INPUT_FAILURE_THRESHOLD:-error}"
UPDATE="${INPUT_UPDATE:-false}"
SKIP_DNS_CHECK="${INPUT_SKIP_DNS_CHECK:-false}"

# Validate command
case "$COMMAND" in
    lint|breaking|check-dns|status|publish)
        ;;
    *)
        error "Invalid command: $COMMAND. Must be one of: lint, breaking, check-dns, status, publish"
        ;;
esac

# Validate lexicon path exists
if [ ! -d "$LEXICON_PATH" ]; then
    error "Lexicon path does not exist: $LEXICON_PATH"
fi

echo "Running goat lex $COMMAND with lexicons from: $LEXICON_PATH"

# Initialize result variables
EXIT_CODE=0
RESULT=""
HAS_ERRORS="false"
HAS_WARNINGS="false"
HAS_CHANGES="false"

# Common args for lexicon directory
LEXICON_ARGS="--lexicons-dir=$LEXICON_PATH"

case "$COMMAND" in
    lint)
        echo "::group::Linting lexicon files"

        if [ "$JSON_OUTPUT" = "true" ]; then
            # shellcheck disable=SC2086
            RESULT=$(goat lex lint $LEXICON_ARGS --json 2>&1 | jq --slurp '.' || echo "[]")
            echo "$RESULT" | jq '.'

            # Check for errors in JSON output
            HAS_ERRORS=$(echo "$RESULT" | jq 'any(."lint-level" | . == "error")' 2>/dev/null || echo "false")
            HAS_WARNINGS=$(echo "$RESULT" | jq 'any(."lint-level" | . == "warning")' 2>/dev/null || echo "false")
        else
            # shellcheck disable=SC2086
            # Note: goat lint may return non-zero for any issues (warnings or errors)
            # so we ignore the exit code and check the output content instead
            RESULT=$(goat lex lint $LEXICON_ARGS 2>&1) || true
            echo "$RESULT"

            # Check for warnings in text output (yellow circle)
            if echo "$RESULT" | grep -q "🟡"; then
                HAS_WARNINGS="true"
            fi
            # Check for errors in text output (red circle)
            if echo "$RESULT" | grep -q "🔴"; then
                HAS_ERRORS="true"
            fi
        fi

        echo "::endgroup::"

        # Determine exit behavior based on failure-threshold
        case "$FAILURE_THRESHOLD" in
            none)
                # Never fail, just report results
                if [ "$HAS_ERRORS" = "true" ]; then
                    warning "Lint check found errors (failure-threshold: none)"
                elif [ "$HAS_WARNINGS" = "true" ]; then
                    warning "Lint check found warnings"
                else
                    notice "Lint check passed"
                fi
                ;;
            warning)
                # Fail on warnings or errors
                if [ "$HAS_ERRORS" = "true" ]; then
                    EXIT_CODE=1
                    error "Lint check found errors"
                elif [ "$HAS_WARNINGS" = "true" ]; then
                    EXIT_CODE=1
                    error "Lint check found warnings (failure-threshold: warning)"
                else
                    notice "Lint check passed"
                fi
                ;;
            error|*)
                # Default: only fail on errors
                if [ "$HAS_ERRORS" = "true" ]; then
                    EXIT_CODE=1
                    error "Lint check found errors"
                elif [ "$HAS_WARNINGS" = "true" ]; then
                    warning "Lint check found warnings"
                else
                    notice "Lint check passed"
                fi
                ;;
        esac
        ;;

    breaking)
        echo "::group::Checking for breaking changes"

        # shellcheck disable=SC2086
        if ! RESULT=$(goat lex breaking $LEXICON_ARGS 2>&1); then
            HAS_ERRORS="true"
            EXIT_CODE=1
        fi
        echo "$RESULT"

        echo "::endgroup::"

        if [ "$HAS_ERRORS" = "true" ]; then
            error "Breaking changes detected"
        else
            notice "No breaking changes detected"
        fi
        ;;

    check-dns)
        if [ -z "$DID" ]; then
            error "DID is required for check-dns command"
        fi

        echo "::group::Checking DNS records for DID: $DID"

        # shellcheck disable=SC2086
        if ! RESULT=$(goat lex check-dns $LEXICON_ARGS --example-did "$DID" 2>&1); then
            HAS_ERRORS="true"
            EXIT_CODE=1
        fi
        echo "$RESULT"

        echo "::endgroup::"

        if [ "$HAS_ERRORS" = "true" ]; then
            error "DNS check failed"
        else
            notice "DNS check passed"
        fi
        ;;

    status)
        echo "::group::Checking lexicon status against network"

        # shellcheck disable=SC2086
        if ! RESULT=$(goat lex status $LEXICON_ARGS 2>&1); then
            HAS_CHANGES="true"
        fi
        echo "$RESULT"

        # Check for status indicators showing changes
        if echo "$RESULT" | grep -qE "🟡|🔴|🟠|🟣"; then
            HAS_CHANGES="true"
        fi

        echo "::endgroup::"

        if [ "$HAS_CHANGES" = "true" ]; then
            notice "Lexicon status check found differences from network"
        else
            notice "Lexicons are in sync with network"
        fi
        ;;

    publish)
        # Validate credentials
        if [ -z "$GOAT_USERNAME" ]; then
            error "Username is required for publish command"
        fi
        if [ -z "$GOAT_PASSWORD" ]; then
            error "Password is required for publish command"
        fi

        # Mask password in logs
        echo "::add-mask::$GOAT_PASSWORD"

        echo "::group::Publishing lexicons"

        # Build command arguments
        PUBLISH_ARGS="$LEXICON_ARGS"
        if [ "$UPDATE" = "true" ]; then
            PUBLISH_ARGS="$PUBLISH_ARGS --update"
        fi
        if [ "$SKIP_DNS_CHECK" = "true" ]; then
            PUBLISH_ARGS="$PUBLISH_ARGS --skip-dns-check"
        fi

        # Run publish command
        # shellcheck disable=SC2086
        if ! RESULT=$(goat lex publish $PUBLISH_ARGS 2>&1); then
            HAS_ERRORS="true"
            EXIT_CODE=1
        fi
        echo "$RESULT"

        echo "::endgroup::"

        if [ "$HAS_ERRORS" = "true" ]; then
            error "Publishing failed"
        else
            notice "Publishing completed successfully"
        fi
        ;;
esac

# Set outputs
output "result" "$RESULT"
output "has-errors" "$HAS_ERRORS"
output "has-warnings" "$HAS_WARNINGS"
output "has-changes" "$HAS_CHANGES"

exit $EXIT_CODE
