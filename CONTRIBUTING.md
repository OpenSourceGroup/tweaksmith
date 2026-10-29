# Contributing to Tweaksmith

Thank you for helping make Macs more personal—safely and reversibly.

## Before you start

1. Read [`docs/PRODUCT_PRINCIPLES.md`](docs/PRODUCT_PRINCIPLES.md)
2. Check [`docs/ROADMAP.md`](docs/ROADMAP.md) and open issues for `now` / approved work
3. For ideas from Grok/research, follow [`docs/RESEARCH_AGENT.md`](docs/RESEARCH_AGENT.md) — no implementation until approved

## Development setup

```bash
git clone <repo-url>
cd tweaksmith
./scripts/bootstrap-check.sh
```

Build/test commands appear when `Package.swift` or an Xcode project is added.

## Pull requests

- Use the PR template checklist
- **Tests:** isolated preference domains only — never mutate CI runner global preferences
- **Settings Engine:** all preference writes through engine APIs
- **Support:** browser-only URLs; never honor `?paid=true`
- Update `CHANGELOG.md` under `[Unreleased]` for user-visible changes
- One logical change per PR when possible

## Code style

- Swift 6 / SwiftUI conventions matching existing files
- MIT header on new source files: `Copyright (c) 2026 Kamyab Infotech Private Limited`

## Labels

See [`.github/LABELS.md`](.github/LABELS.md). Maintainers set roadmap labels.

## Release

Contributors do not ship production releases. Maintainers run [`docs/RELEASE_PROCESS.md`](docs/RELEASE_PROCESS.md) and [`docs/RELEASE_GATE.md`](docs/RELEASE_GATE.md).

## Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Questions

Open a GitHub Discussion or issue with the appropriate template.
