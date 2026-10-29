# Contributing to Tweaksmith

Thank you for helping make Macs more personal—safely and reversibly.

## Before you start

1. Read [`docs/PRODUCT_PRINCIPLES.md`](docs/PRODUCT_PRINCIPLES.md)
2. Check [`docs/ROADMAP.md`](docs/ROADMAP.md) and open issues for `now` / approved work
3. Skim [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) for Settings Engine and test rules

## Development setup

```bash
git clone https://github.com/OpenSourceGroup/tweaksmith.git
cd tweaksmith
./scripts/bootstrap-check.sh
./scripts/run-smoke.sh
```

```bash
swift test   # requires full Xcode; otherwise use run-smoke.sh
```

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

## Labels / board

See [`.github/LABELS.md`](.github/LABELS.md) and [`docs/PROJECT_BOARD.md`](docs/PROJECT_BOARD.md). Maintainers set roadmap labels (`now` / `next` / `later` / …).

## Release

Contributors do not ship production releases. Maintainers run [`docs/RELEASE_PROCESS.md`](docs/RELEASE_PROCESS.md) and [`docs/RELEASE_GATE.md`](docs/RELEASE_GATE.md).

## Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Questions

Open a GitHub Discussion or issue with the appropriate template.
