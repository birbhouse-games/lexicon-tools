# ATProto Lexicon Tools

A collection of GitHub Actions for working with ATProto lexicons using the official [goat CLI](https://github.com/bluesky-social/goat).

## Available Actions

| Action | Description |
|--------|-------------|
| [`lint`](#lint) | Lint lexicon files for syntax and style issues |
| [`breaking`](#breaking) | Check for breaking changes against the network |
| [`check-dns`](#check-dns) | Verify DNS records for lexicon namespaces |
| [`status`](#status) | Check local lexicon status against the network |
| [`publish`](#publish) | Publish lexicons to the ATProto network |

## Usage

### Lint

Validates lexicon files for syntax errors, style issues, and best practices.

```yaml
- name: Lint Lexicons
  uses: birbhouse-games/lexicon-tools/lint@v1
  with:
    lexicon-path: ./lexicons
    json-output: 'true'       # Optional: output JSON for parsing
    fail-on-warning: 'true'   # Optional: fail on warnings
```

**Inputs:**
| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |
| `json-output` | Output in JSON format | No | `false` |
| `fail-on-warning` | Fail if warnings found | No | `false` |

**Outputs:**
| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-errors` | Whether errors were found |
| `has-warnings` | Whether warnings were found |

---

### Breaking

Checks for breaking changes between local lexicons and those published on the network.

```yaml
- name: Check Breaking Changes
  uses: birbhouse-games/lexicon-tools/breaking@v1
  with:
    lexicon-path: ./lexicons
```

**Inputs:**
| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |

**Outputs:**
| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-errors` | Whether breaking changes were found |

---

### Check DNS

Verifies DNS records are correctly configured for your lexicon namespace.

```yaml
- name: Check DNS Records
  uses: birbhouse-games/lexicon-tools/check-dns@v1
  with:
    lexicon-path: ./lexicons
    did: ${{ vars.DID }}
```

**Inputs:**
| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |
| `did` | DID to verify DNS against | **Yes** | - |

**Outputs:**
| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-errors` | Whether DNS check failed |

---

### Status

Shows the status of local lexicons compared to what's published on the network.

```yaml
- name: Check Lexicon Status
  uses: birbhouse-games/lexicon-tools/status@v1
  with:
    lexicon-path: ./lexicons
```

**Inputs:**
| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |

**Outputs:**
| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-changes` | Whether differences exist |

---

### Publish

Publishes lexicon schemas to the ATProto network.

```yaml
- name: Publish Lexicons
  uses: birbhouse-games/lexicon-tools/publish@v1
  with:
    lexicon-path: ./lexicons
    username: ${{ secrets.ATPROTO_HANDLE }}
    password: ${{ secrets.ATPROTO_APP_PASSWORD }}
    update: 'true'            # Optional: update existing schemas
    skip-dns-check: 'false'   # Optional: skip DNS validation
```

**Inputs:**
| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `lexicon-path` | Path to lexicon files | No | `.` |
| `username` | ATProto handle or DID | **Yes** | - |
| `password` | ATProto app password | **Yes** | - |
| `update` | Update existing schemas | No | `false` |
| `skip-dns-check` | Skip DNS validation | No | `false` |

**Outputs:**
| Output | Description |
|--------|-------------|
| `result` | Raw command output |
| `has-errors` | Whether publishing failed |

---

## Complete CI Example

```yaml
name: Lexicon CI
on:
  pull_request:
    paths:
      - 'lexicons/**'
  push:
    branches: [main]
    paths:
      - 'lexicons/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint Lexicons
        uses: birbhouse-games/lexicon-tools/lint@v1
        with:
          lexicon-path: ./lexicons
          fail-on-warning: 'true'

      - name: Check Breaking Changes
        uses: birbhouse-games/lexicon-tools/breaking@v1
        with:
          lexicon-path: ./lexicons

      - name: Check DNS Records
        uses: birbhouse-games/lexicon-tools/check-dns@v1
        with:
          lexicon-path: ./lexicons
          did: ${{ vars.DID }}

  publish:
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Publish Lexicons
        uses: birbhouse-games/lexicon-tools/publish@v1
        with:
          lexicon-path: ./lexicons
          username: ${{ secrets.ATPROTO_HANDLE }}
          password: ${{ secrets.ATPROTO_APP_PASSWORD }}
          update: 'true'
```

## Security

### App Passwords

**Never use your main account password.** Always create an app password:

1. Log into your ATProto account (e.g., Bluesky)
2. Navigate to **Settings → Privacy and Security → App Passwords**
3. Create a new app password with a descriptive name
4. Store it in GitHub Secrets as `ATPROTO_APP_PASSWORD`

The password is automatically masked in logs.

## License

See [LICENSE](LICENSE) for details.
