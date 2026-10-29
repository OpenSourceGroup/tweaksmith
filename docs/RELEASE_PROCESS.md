# Release Process

Official releases are published by authorized maintainers. **Kamyab Infotech** is the current lead maintainer. Builds are signed and notarized when CI secrets exist, then published to GitHub Releases and the website ([kamyab.co.in](https://kamyab.co.in)).

---

## Overview

```
feature branch → PR → main (CI green)
  → workflow_dispatch: Release Candidate (tag v0.1.0-rc.N)
  → docs/RELEASE_GATE.md (+ scripts/release-gate.sh)
  → fix blockers or document limitations
  → workflow_dispatch: Release (requires production approval)
  → notarize (if secrets) → checksums → GitHub Release → website update
```

---

## Release Candidate (RC)

1. Ensure `CHANGELOG.md` has `Unreleased` entries ready to move under `0.1.0-rc.N`
2. Run full test suite locally or rely on CI green on `main`
3. Trigger **Release Candidate** workflow (`.github/workflows/release-candidate.yml`):
   - Input version (e.g. `0.1.0-rc.1`)
   - Creates tag `v0.1.0-rc.1`
   - Runs `scripts/package-release.sh` (SwiftPM `.app` wrap; `xcodebuild` optional when Xcode.app exists)
   - Signs/notarizes **if** Apple secrets configured; otherwise UNSIGNED/AD-HOC zip marked not for Gatekeeper
   - Uploads checksums (SHA-256); never logs secrets; draft pre-release when unsigned
4. Run **Release Gate** checklist; record verdict in RC issue
5. QA on Apple Silicon + Tahoe 26 hardware

---

## Gate

- Independent pass of `docs/RELEASE_GATE.md`
- Verdict: `READY` | `READY WITH KNOWN LIMITATIONS` | `BLOCKED`
- `BLOCKED` → no production release; RC may iterate

---

## Production release

1. Maintainer opens/updates release issue; confirms gate verdict
2. Trigger **Release** workflow (`.github/workflows/release.yml`):
   - Requires GitHub Environment **`production`** manual approval
   - Tag `v0.1.0` (semver)
3. Workflow steps (when implemented):
   - Build release configuration
   - Sign + notarize if `APPLE_*` secrets present; skip gracefully if absent with clear log line
   - Generate `SHA256SUMS` for distributables
   - Create GitHub Release with notes from CHANGELOG
4. Update website download links and version string
5. Close release-blocker issues; bump CHANGELOG

---

## Versioning

- SemVer: `MAJOR.MINOR.PATCH`
- Pre-release: `-rc.N`
- Git tags: `v0.1.0-rc.1`, `v0.1.0`

---

## Secrets (GitHub Actions)

Expected **optional** secrets for signing (names illustrative—configure in repo settings):

- Apple Developer ID certificate + password
- Notarization credentials
- Never commit; never echo in logs

If secrets missing, workflows produce unsigned artifacts for local dev only—not for public “official” channel.

---

## Hotfix

1. Branch from release tag
2. Minimal fix + test
3. Patch version + expedited gate
4. Production workflow with approval

---

## Rollback

- Public: publish previous GitHub Release asset + website pointer
- User data: instruct **Restore All** in app; no remote kill switch

---

## Manual approval rule

**Production** workflow must not complete without human approval in `production` environment—no fully automated ship to users.

---

## Backlog columns

Engineering priority uses issue labels / milestones (Projects v2 optional later). Map: [`PROJECT_BOARD.md`](PROJECT_BOARD.md) — Inbox → Now → Next → Later → Experimental → Wont build → In Progress → QA → Released.

See also: `RELEASE_GATE.md`, `PRODUCT_PRINCIPLES.md`.
