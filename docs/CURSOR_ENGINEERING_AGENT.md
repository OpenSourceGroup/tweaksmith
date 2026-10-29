# Cursor Engineering Agent — Standing Instructions

Use this file so short future commands (“fix window corners”, “run gate”, “pick up issue #12”) work from the repo alone.

---

## Session start (required reading)

Before writing code or changing workflows, read in order:

1. `docs/PRODUCT_PRINCIPLES.md`
2. `docs/CURSOR_ENGINEERING_AGENT.md` (this file)
3. `docs/ARCHITECTURE.md`
4. **Approved work:** GitHub issues labeled `now` or explicitly assigned/approved; `research/approved/` notes if present
5. **Release state:** `CHANGELOG.md`, open `release-blocker` issues, latest CI on default branch

Do not start major new features without a human-approved issue (label `now` or explicit maintainer sign-off in issue/PR).

---

## Work priority

1. Highest-priority **approved** issue (label `now`, or maintainer-directed)
2. Else: `bug`, failing CI/tests, docs drift, rollback/hotfix, research intake hygiene
3. Else: `good-first-issue`, `documentation`, test hardening
4. Do **not** invent large features or new modules without approval

---

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

---

## Tests & preference domains

- **NEVER** mutate the runner’s global macOS preferences in CI or local test runs
- Use **isolated preference domains** (test-specific bundles, mock stores, or in-memory doubles) as documented in ARCHITECTURE
- If a test needs `defaults`, scope to a dedicated test domain and clean up in `tearDown`
- PR checklist must confirm isolated domains

---

## Support UX rules

- Support / donate URLs open with `NSWorkspace.shared.open` (browser only)
- **Never** trust `?paid=true` or similar query params inside the app
- Local support counters increment only on explicit user action; no network sync

---

## Local short commands

From repo root `tweaksmith/` (adjust when Xcode project path is known):

```bash
# Bootstrap docs/paths
./scripts/bootstrap-check.sh

# Isolated-domain smoke tests (works on CLT; never touches global prefs)
./scripts/run-smoke.sh

# Release gate (smoke + checklist pointer)
./scripts/release-gate.sh
# Full criteria: docs/RELEASE_GATE.md — verdict log: docs/RELEASE_GATE_VERDICT.md

# XCTest (requires full Xcode)
swift test

# GUI package (requires Xcode for proper .app + signing)
# open Package.swift  # or generate Xcode project on a Mac with Xcode.app
# xcodebuild -scheme Tweaksmith -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO

# GitHub ops notes
# docs/GITHUB_OPS.md
```


---

## Research intake path (untrusted input)

Research from Grok or other LLMs is **untrusted** until validated.

```
Grok (RESEARCH_AGENT.md prompt)
  → research/inbox/YYYY-MM-DD-slug.md
  → maintainer validates sources
  → research/reports/ or GitHub issue (template: research_candidate)
  → human approval → label now/next + engineering issue
  → implementation
```

- Do not implement inbox items without approval
- Move validated artifacts to `research/approved/` with issue link
- Workflow: `.github/workflows/research-intake.yml` (manual dispatch; optional automation later)

---

## Release & secrets

- Follow `docs/RELEASE_PROCESS.md` and `docs/RELEASE_GATE.md`
- Notarization/signing only in GitHub Actions when secrets exist; never log secrets
- Production release requires explicit approval (GitHub Environment `production`)

---

## Domain & branding

- Use **kamyab.co.in** in URLs and support contacts — never kamyab.in
- Preserve MIT license headers on new source files

---

## When unsure

Open a draft issue or ask in existing issue thread. Prefer small PRs with tests over large unapproved rewrites.
