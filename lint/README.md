# Lint ATProto Lexicons

Validates lexicon files for syntax errors, style issues, and best practices using the [goat CLI](https://github.com/bluesky-social/goat).

## Usage

```yaml
- name: Lint Lexicons
  uses: birbhouse-games/lexicon-tools/lint@v1
  with:
    lexicon-path: ./lexicons
    json-output: 'true'           # Optional: output JSON for parsing
    failure-threshold: 'error'    # Optional: when to fail (error/warning/none)
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |
| `json-output` | Output in JSON format | No | `false` |
| `failure-threshold` | When to fail the action: `error` (default), `warning`, or `none` | No | `error` |

### Failure Threshold Options

- **`error`** (default): Only fail if errors are found
- **`warning`**: Fail if warnings or errors are found
- **`none`**: Never fail (just report results)

## Outputs

| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-errors` | Whether errors were found (`true`/`false`) |
| `has-warnings` | Whether warnings were found (`true`/`false`) |

## Example

```yaml
- name: Lint Lexicons
  id: lint
  uses: birbhouse-games/lexicon-tools/lint@v1
  with:
    lexicon-path: ./src
    failure-threshold: error

- name: Check results
  run: |
    echo "Has errors: ${{ steps.lint.outputs.has-errors }}"
    echo "Has warnings: ${{ steps.lint.outputs.has-warnings }}"
```
