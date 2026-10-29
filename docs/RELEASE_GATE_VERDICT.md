# Release Gate Verdict — v0.1.0

**Date:** 2026-10-30 (independent re-run)  
**Evaluator:** Maintainer checklist against `docs/RELEASE_GATE.md`  
**Candidate:** Tweaksmith 0.1.0 (public Gatekeeper channel)  
**Host:** macOS 27.2 / Build 26B123 (Tahoe 26 family), arm64, Command Line Tools only (no Xcode.app)

## Verdict

**READY WITH KNOWN LIMITATIONS**

Public **READY** for Gatekeeper v0.1.0 is **not** met. Unsigned RC packaging and preview site remain acceptable for continued development; do not publish as official download.

## Evidence summary

| Area | Result |
|------|--------|
| Canonical GitHub | PASS — `OpenSourceGroup/tweaksmith` public, `main`, MIT; `KamyabInfotech/tweaksmith` → 301 |
| History / CI | PASS — 8 commits preserved; CI green on `b21283d`; workflows active; branch protection requires `test` |
| Public repo sanitization | PASS — no live secrets; private product-ops machinery not in tree; harmless `Co-authored-by: Cursor` trailers left in history (no rewrite) |
| Settings Engine smoke | PASS — `./scripts/run-smoke.sh` (isolated domains) |
| XCTest suite | BLOCKED — needs full Xcode.app (`import XCTest` unavailable under CLT) |
| Window Corners prefs | PASS (lifecycle) — Override1 APPLY 4/8/10/custom, restore previous, reset default; Override2 absent/unexposed |
| Window Corners visual | LIMITATION — sample-app chrome not claimed without logout/reopen cycle |
| Support prompt + URL | PASS — browser-only; no `?paid=true` trust; OSG/Kamyab attribution in About |
| Preview Razorpay | PASS (safe) — checkout disabled; create-order blocked; production endpoint absent (404) |
| Official website (prod) | LIMITATION — `https://kamyab.co.in/tweaksmith` **404** until site deploy; preview OK with “coming soon” |
| Signed official binary | BLOCKED — 0 Developer ID identities; no notary credentials |
| Production payments | NOT enabled (correct; not a release blocker) |

## Artifact (unsigned RC only)

| Item | Value |
|------|--------|
| App zip | `dist/Tweaksmith-0.1.0-rc.1-macos-arm64-UNSIGNED-NOT-FOR-GATEKEEPER.zip` |
| SHA-256 (app zip) | `f3af9bd57640f3de704b8bdb2de91507a703eb807dbf18962276aa53d9e51505` |
| Signing | `unsigned-adhoc` |
| Notarized | no |
| Gatekeeper public OK | no |
| Draft release | https://github.com/OpenSourceGroup/tweaksmith/releases/tag/untagged-41150195228ac06dbe05 (draft, not public) |

## Known limitations

1. No full Xcode.app / XCTest / Developer ID / notarization on this host
2. Override2 absent — not in UI
3. Window Corners visual effect may need quit apps / logout / restart; no universal app-compatibility claim
4. Preview payments disabled until `rzp_test_*` minted (optional)
5. Unsigned draft only — not Gatekeeper channel
6. Production product pages not deployed yet (404)
7. GST/invoice for support: undefined for v0.1

## Blockers for public “official” v0.1.0 READY

1. Install full **Xcode.app**, `xcode-select` to it, run `swift test` + Release archive path
2. Import **Developer ID Application** identity into Keychain (or CI secrets)
3. Configure **notarytool** credentials (never commit); sign → notarize Accepted → staple → `spctl` assess
4. Clean-install test of stapled artifact
5. Human publish of GitHub Release + point website download at notarized OSG Release (not unsigned draft)
6. Deploy production `kamyab.co.in/tweaksmith` (+ support) when ready — keep payments off until approved

## Re-run

```bash
./scripts/release.sh 0.1.0
```
