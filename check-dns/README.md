# Check Lexicon DNS Records

Verifies DNS records are correctly configured for your lexicon namespaces using the [goat CLI](https://github.com/bluesky-social/goat).

## Usage

```yaml
- name: Check DNS Records
  uses: birbhouse-games/lexicon-tools/check-dns@v1
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
| `has-errors` | Whether DNS check failed (`true`/`false`) |

## Example

```yaml
- name: Check DNS Records
  id: dns
  uses: birbhouse-games/lexicon-tools/check-dns@v1
  with:
    lexicon-path: ./src

- name: DNS check passed
  if: steps.dns.outputs.has-errors == 'false'
  run: echo "DNS records are correctly configured"
```
