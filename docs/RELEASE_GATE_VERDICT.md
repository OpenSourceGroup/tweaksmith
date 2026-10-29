# Release Gate Verdict — Developer Preview 2 (`v0.1.0-dev.2`)

**Date:** 2026-10-30  
**Evaluator:** Maintainer checklist against `docs/RELEASE_GATE.md`  
**Candidate:** Tweaksmith 0.1.0-dev.2 (Developer Preview 2)  
**Host:** macOS 27.2 / arm64

## Split status (do not conflate)

| Channel | Status |
|---------|--------|
| **GitHub Developer Preview 2** (unsigned pre-release) | **RELEASED** — tag `v0.1.0-dev.2`, GitHub **pre-release** |
| **Stable / Gatekeeper v0.1** | **BLOCKED** — Developer ID Application + notarization **DEFERRED** |
| **Clean tag `v0.1.0`** | Reserved for eventual signed stable (DP1 historically used this tag; do not rewrite) |
| **Voluntary payments** | Untouched this session — optional, no unlock |

Do **not** call the unsigned Developer Preview “stable” or the official Gatekeeper download.

## Evidence summary

| Area | Result |
|------|--------|
| Core manual QA | **PASS** — Apply Sharp→4, Changes entry, Restore Previous/Original, Reset, relaunch |
| Global prefs write | **FIXED** — `CFPreferences` / NSGlobalDomain (was wrongly app-domain) |
| Smoke | **PASS** — `./scripts/run-smoke.sh` |
| Artifact | `Tweaksmith-0.1.0-Developer-Preview-2-macOS.zip` (unsigned / ad-hoc) |
| `codesign --verify --deep --strict` | **PASS** after clean extract |
| `spctl --assess` | **rejected** (expected unsigned) |
| Developer ID Application | **MISSING** — deferred |
| Notarization | **MISSING** — deferred |

## Blockers for Stable Gatekeeper v0.1.0

1. Import **Developer ID Application** certificate
2. Store **notarytool** credentials
3. Sign → notarize Accepted → staple → `spctl --assess`
4. Publish a separate Stable channel artifact (not this Developer Preview)

## Known limitations

1. Unsigned / not Developer ID signed — macOS may require Privacy & Security → Open Anyway
2. Window Corners adjusts preference used by supported apps only; logout/restart may be required
3. `NSConvolutionOverride2` not exposed
4. Packaging is SwiftPM `.app` wrap (not `xcodebuild` archive)
