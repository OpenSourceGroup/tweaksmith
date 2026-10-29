# Release Gate Verdict — v0.1.0

**Date:** 2026-10-30 (Developer Preview publish + voluntary payments)  
**Evaluator:** Maintainer checklist against `docs/RELEASE_GATE.md`  
**Candidate:** Tweaksmith 0.1.0  
**Host:** macOS 27.2 / arm64, **Xcode 27.1** at `/Applications/Xcode.app/Contents/Developer`

## Split status (do not conflate)

| Channel | Status |
|---------|--------|
| **GitHub Developer Preview** (unsigned pre-release) | **RELEASED** — tag `v0.1.0`, GitHub **pre-release** |
| **Stable / Gatekeeper v0.1** | **BLOCKED** — Developer ID Application + notarization **DEFERRED** |
| **Voluntary payments** | Independent of signing — see Payments section in session report |

Do **not** call the unsigned Developer Preview “stable” or the official Gatekeeper download.

## Evidence summary

| Area | Result |
|------|--------|
| Selected developer path | `/Applications/Xcode.app/Contents/Developer` |
| Xcode | **27.1** (Build 27A9275) |
| XCTest | **PASS** — 12 tests, 0 failures (`scripts/run-swift-test.sh`) |
| Core smoke | **PASS** — `./scripts/run-smoke.sh` |
| Debug / Release build | **PASS** — SwiftPM |
| Developer ID Application | **MISSING** — deferred |
| notary Keychain profile | **MISSING** — deferred |
| Developer Preview artifact | `Tweaksmith-0.1.0-Developer-Preview-macOS.zip` (unsigned / ad-hoc) |

## Blockers for Stable Gatekeeper v0.1.0

1. Import **Developer ID Application** certificate
2. Store **notarytool** credentials (`xcrun notarytool store-credentials`)
3. Sign → notarize Accepted → staple → `spctl --assess`
4. Publish a separate Stable channel artifact (not this Developer Preview)

## Known limitations

1. Unsigned / not Developer ID signed — macOS may require Privacy & Security → Open Anyway
2. Override2 absent — not in UI
3. Window Corners adjusts preference used by supported apps; may need quit/logout/restart
4. GST/invoice for support: undefined for v0.1 — contact support@kamyab.co.in

## Re-run (after Developer ID + notary profile)

```bash
./scripts/release.sh 0.1.0
```
