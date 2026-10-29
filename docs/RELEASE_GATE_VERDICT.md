# Release Gate Verdict — v0.1 RC

**Date:** 2026-10-29 (post-sanitization + preview payment disable)  
**Evaluator:** Maintainer checklist against `docs/RELEASE_GATE.md`  
**Candidate:** Tweaksmith 0.1.0-rc.1  
**Host:** macOS 27.2 / Build 26B123 (Tahoe 26 family), arm64 M5 Pro, Command Line Tools only (no Xcode.app)

## Verdict

**READY WITH KNOWN LIMITATIONS**

## Evidence summary

| Area | Result |
|------|--------|
| Public repo sanitization | PASS — research/agent internals moved to private `tweaksmith-intelligence`; CI green on `65cd986` |
| Settings Engine lifecycle | PASS — `./scripts/run-smoke.sh` green |
| Window Corners | PASS with limitations — Override1 QA on host; Override2 absent/not exposed; radius sanitisation added |
| Support prompt + URL | PASS — browser-only `kamyab.co.in`; no `?paid=true` trust |
| Isolated prefs in tests | PASS |
| Preview Razorpay | PASS (safe) — LIVE secrets removed; create-order **503**; UI “Checkout disabled on preview” |
| Release packaging | PASS (unsigned) — SwiftPM `.app` zip + SHA-256 |
| Signed official binary | BLOCKED — 0 Developer ID identities; no notarization |
| Production payments | NOT enabled (correct) |

## Artifact

| Item | Value |
|------|--------|
| App zip | `dist/Tweaksmith-0.1.0-rc.1-macos-arm64-UNSIGNED-NOT-FOR-GATEKEEPER.zip` |
| SHA-256 (app zip) | `f3af9bd57640f3de704b8bdb2de91507a703eb807dbf18962276aa53d9e51505` |
| Signing | `unsigned-adhoc` |
| Notarized | no |
| Gatekeeper public OK | no |
| Draft release | https://github.com/KamyabInfotech/tweaksmith/releases/tag/untagged-446375ca22eeecae2e81 |

## Known limitations

1. No full Xcode.app / Developer ID / notarization on this host
2. Override2 absent — not in UI
3. Window Corners may need logout/restart; visual sample-app pass incomplete without logout
4. Preview payments disabled until `rzp_test_*` minted
5. Unsigned draft only — not Gatekeeper channel
6. GST/invoice for support: undefined for v0.1

## Blockers for public “official” v0.1

- Xcode + Developer ID + notarization credentials
- Human RELEASE_GATE after notarized artifact
- Optional: mint Razorpay TEST for staging demos; separate approval for production LIVE

## Re-run

```bash
./scripts/release.sh 0.1.0-rc.1
```
