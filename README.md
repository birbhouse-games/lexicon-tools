# ATProto Lexicon Tools

A collection of GitHub Actions for working with ATProto lexicons using the official [goat CLI](https://github.com/bluesky-social/goat).

## Available Actions

| Action | Description |
|--------|-------------|
| [**lint**](./lint/README.md) | Lint lexicon files for syntax and style issues |
| [**breaking**](./breaking/README.md) | Check for breaking changes against the network |
| [**check-dns**](./check-dns/README.md) | Verify DNS records for lexicon namespaces |
| [**status**](./status/README.md) | Check local lexicon status against the network |
| [**publish**](./publish/README.md) | Publish lexicons to the ATProto network |

## Quick Start

```yaml
name: Lexicon CI/CD

on:
  pull_request:
    paths: ['lexicons/**']
  push:
    branches: [main]
    paths: ['lexicons/**']

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint
        uses: birbhouse-games/lexicon-tools/lint@v1
        with:
          lexicon-path: ./lexicons

      - name: Check Breaking Changes
        uses: birbhouse-games/lexicon-tools/breaking@v1
        with:
          lexicon-path: ./lexicons

  publish:
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Publish
        uses: birbhouse-games/lexicon-tools/publish@v1
        with:
          lexicon-path: ./lexicons
          username: ${{ vars.ATPROTO_HANDLE }}
          password: ${{ secrets.ATPROTO_APP_PASSWORD }}
          update: 'true'
```

## License

See [LICENSE](LICENSE) for details.
