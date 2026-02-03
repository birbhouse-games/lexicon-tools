# Publish ATProto Lexicons

Publishes lexicon schemas to the ATProto network using the [goat CLI](https://github.com/bluesky-social/goat).

## Usage

```yaml
- name: Publish Lexicons
  uses: birbhouse-games/lexicon-tools/publish@v1
  with:
    lexicon-path: ./lexicons
    username: ${{ vars.ATPROTO_HANDLE }}
    password: ${{ secrets.ATPROTO_APP_PASSWORD }}
    update: 'true'            # Optional: update existing schemas
    skip-dns-check: 'false'   # Optional: skip DNS validation
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |
| `username` | ATProto handle or DID | **Yes** | - |
| `password` | ATProto app password | **Yes** | - |
| `update` | Update existing schemas | No | `false` |
| `skip-dns-check` | Skip DNS validation | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-errors` | Whether publishing failed (`true`/`false`) |

## Security

### App Passwords

**Never use your main account password.** Always create an app password:

1. Log into your ATProto account (e.g., Bluesky)
2. Navigate to **Settings → Privacy and Security → App Passwords**
3. Create a new app password with a descriptive name
4. Store it in GitHub Secrets (e.g., `ATPROTO_APP_PASSWORD`)

The password is automatically masked in workflow logs.

## Example

```yaml
publish:
  runs-on: ubuntu-latest
  if: github.ref == 'refs/heads/main'
  steps:
    - uses: actions/checkout@v4

    - name: Publish Lexicons
      uses: birbhouse-games/lexicon-tools/publish@v1
      with:
        lexicon-path: ./src
        username: ${{ vars.ATPROTO_HANDLE }}
        password: ${{ secrets.ATPROTO_APP_PASSWORD }}
        update: 'true'
```
