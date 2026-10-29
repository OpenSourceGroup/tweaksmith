# Release Gate Verdict — v0.1 RC

**Date:** 2026-10-29 (re-run after packaging)  
**Evaluator:** Maintainer checklist against `docs/RELEASE_GATE.md`  
**Candidate:** Tweaksmith 0.1.0-rc.1  
**Host:** macOS 27.2 / Build 26B123 (Tahoe 26 family), arm64, Command Line Tools only (no Xcode.app)

## Verdict

**READY WITH KNOWN LIMITATIONS**

## Evidence summary

| Area | Result |
|------|--------|
| Settings Engine lifecycle | PASS — `./scripts/run-smoke.sh` all green (READ/BACKUP/APPLY/VERIFY/RESTORE/RESET/external/compatibility) |
| Window Corners module | PASS with limitations — Override1 validated in smoke; Override2 not exposed when absent |
| Support prompt logic | PASS — first-launch suppress, ≥3 actions, 30-day wait, max 3, dont-ask, manual open; host `kamyab.co.in` |
| Isolated prefs in tests | PASS — CI backend forbids global domain writes |
| Native UI shell | PASS (source + SwiftPM release binary) — `.app` packaged via `scripts/package-release.sh` |
| Release packaging | PASS (unsigned) — arm64 `.app` zip + binary zip + SHA-256 + notes produced under `dist/` |
| Website / payments | PARTIAL — support pages staged; preview checkout must not use LIVE keys |
| CI / GitHub | PARTIAL — workflows call `package-release.sh`; draft RC release when assets uploaded |
| Signed official binary | BLOCKED for public Gatekeeper download — no Developer ID / notarize credentials on this host (`security find-identity`: 0 identities) |

## Artifact (this host)

| Item | Value |
|------|--------|
| App zip | `dist/Tweaksmith-0.1.0-rc.1-macos-arm64-UNSIGNED-NOT-FOR-GATEKEEPER.zip` |
| Signing | `unsigned-adhoc` |
| Notarized | no |
| Gatekeeper public OK | no |

See `dist/SHA256SUMS.txt` and `dist/ARTIFACT_META.txt` for checksums and metadata.

## Known limitations (accepted for RC)

1. **No full Xcode.app** — packaging uses SwiftPM executable wrapped as `.app` (ad-hoc codesign). Official archive/notarize needs a signing Mac with Xcode + Developer ID.
2. **`NSConvolutionOverride2`** absent on some hosts — not exposed in UI (correct).
3. **Undocumented preference** — Window Corners risk MEDIUM; logout/restart may be required; preview illustrative.
4. **Payments** — preview must not run LIVE checkout; production cut-over is a separate human decision.
5. **GitHub Projects v2** optional — label+milestone board is the active fallback (`docs/PROJECT_BOARD.md`).
6. **UNSIGNED artifact** must ship only as **draft** / RC — never as the public Gatekeeper channel.

## Blockers for public v0.1 “official” release (not RC)

- Install Xcode (or use CI macos runner with Apple secrets), Developer ID Application identity, notarization credentials
- `scripts/package-release.sh` → `signing_mode=developer-id` and `notarized=yes` / `gatekeeper_public_ok=yes`
- Confirm Window Corners on clean macOS Tahoe 26+ volume
- Staging Razorpay TEST end-to-end, then optional LIVE
- Human RELEASE_GATE re-run after notarized artifact exists

## Commands to re-run

```bash
cd tweaksmith
./scripts/run-smoke.sh
./scripts/package-release.sh 0.1.0-rc.1
./scripts/release-gate.sh
```
