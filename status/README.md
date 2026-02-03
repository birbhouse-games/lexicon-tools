# Check Lexicon Status

Shows the status of local lexicons compared to what's published on the ATProto network using the [goat CLI](https://github.com/bluesky-social/goat).

## Usage

```yaml
- name: Check Lexicon Status
  uses: birbhouse-games/lexicon-tools/status@v1
  with:
    lexicon-path: ./lexicons
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |

## Outputs

| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-changes` | Whether differences exist from the network (`true`/`false`) |

## Example

```yaml
- name: Check Lexicon Status
  id: status
  uses: birbhouse-games/lexicon-tools/status@v1
  with:
    lexicon-path: ./src

- name: Report status
  run: |
    if [ "${{ steps.status.outputs.has-changes }}" == "true" ]; then
      echo "Local lexicons differ from network"
    else
      echo "Lexicons are in sync with network"
    fi
```
