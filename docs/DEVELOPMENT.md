# Development

Working notes for contributors building Tweaksmith.

## Before you change code

1. Read [`PRODUCT_PRINCIPLES.md`](PRODUCT_PRINCIPLES.md)
2. Read [`ARCHITECTURE.md`](ARCHITECTURE.md)
3. Confirm the work matches an open issue with maintainer priority (`now` / `next` / …), or a clear bugfix

Do not start major new modules without a maintainer-approved issue.

## Work priority (maintainers)

1. Approved `now` issues
2. Bugs, failing CI/tests, docs drift, rollback/hotfix
3. `good-first-issue`, `documentation`, test hardening
4. Do not invent large features without approval

## Settings Engine lifecycle

All preference mutations in product code and tests must respect:

| Phase | Purpose |
|-------|---------|
| **READ** | Load current value from domain/key |
| **BACKUP** | Persist snapshot before first change |
| **APPLY** | Write new value through engine only |
| **VERIFY** | Read-back matches intent |
| **HISTORY** | Append audit entry (local) |
| **RESTORE** | Previous / Original / macOS Default / Restore All |
| **RESET** | Domain-level reset per module spec |
| **COMPATIBILITY** | Gate apply on OS version, chip, known conflicts |
| **ERROR** | Surface failure; never silent partial apply |

Never bypass the engine for “quick fixes” in feature modules.

## Tests & preference domains

- **Never** mutate the runner’s global macOS preferences in CI or local test runs
- Use **isolated preference domains** (test-specific bundles, mock stores, or in-memory doubles)
- If a test needs `defaults`, scope to a dedicated test domain and clean up afterward
- PR checklist must confirm isolated domains

## Support UX rules

- Support / donate URLs open with `NSWorkspace.shared.open` (browser only)
- **Never** trust `?paid=true` or similar query params inside the app
- Local support counters increment only on explicit user action; no network sync

## Local commands

```bash
./scripts/bootstrap-check.sh
./scripts/run-smoke.sh
./scripts/release-gate.sh
swift test   # requires full Xcode
./scripts/package-release.sh 0.1.0-rc.1
```

Release criteria: [`RELEASE_GATE.md`](RELEASE_GATE.md). Process: [`RELEASE_PROCESS.md`](RELEASE_PROCESS.md).

## Domain & branding

- Use **kamyab.co.in** in URLs and support contacts — never `kamyab.in`
- Preserve MIT license headers on new source files

## When unsure

Open an issue or ask on an existing thread. Prefer small PRs with tests over large unapproved rewrites.
