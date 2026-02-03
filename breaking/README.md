# Check Lexicon Breaking Changes

Checks for breaking changes between local lexicons and those published on the ATProto network using the [goat CLI](https://github.com/bluesky-social/goat).

## Usage

```yaml
- name: Check Breaking Changes
  uses: birbhouse-games/lexicon-tools/breaking@v1
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
| `has-errors` | Whether breaking changes were found (`true`/`false`) |

## Example

```yaml
- name: Check Breaking Changes
  id: breaking
  uses: birbhouse-games/lexicon-tools/breaking@v1
  with:
    lexicon-path: ./src

- name: Handle breaking changes
  if: steps.breaking.outputs.has-errors == 'true'
  run: echo "Breaking changes detected!"
```
