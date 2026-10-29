# Release Gate Verdict — v0.1.0

**Date:** 2026-10-30 (distribution sync + Apple path re-run)  
**Evaluator:** Maintainer checklist against `docs/RELEASE_GATE.md`  
**Candidate:** Tweaksmith 0.1.0 (public Gatekeeper channel)  
**Host:** macOS 27.2 / Build 26B123 (Tahoe 26 family), arm64, Command Line Tools only (no Xcode.app)

## Verdict

**BLOCKED** (for public Gatekeeper READY) — continue development under **READY WITH KNOWN LIMITATIONS** constraints (unsigned draft only; do not publish as official download).

Public **READY** for Gatekeeper v0.1.0 is **not** met. Primary blockers: full Xcode.app, Developer ID Application identity, notarytool credentials.

## Evidence summary

| Area | Result |
|------|--------|
| Canonical GitHub | PASS — `OpenSourceGroup/tweaksmith` public, `main`, MIT; remote URL confirmed |
| Git sync | PASS — previous `origin/main` `b21283d` → pushed `6ca8a44`; local/remote clean |
| History / CI | PASS — Actions run `40950771496` **success** on `6ca8a44` (job `test`) |
| Public repo sanitization | PASS — no live secrets / Grok / research agent material in tree |
| Settings Engine smoke | PASS prior evidence — `./scripts/run-smoke.sh` (isolated domains) |
| XCTest suite | BLOCKED — needs full Xcode.app (`xcodebuild` unavailable under CLT) |
| Window Corners prefs | PASS (lifecycle, prior) — Override1 APPLY/restore/reset; Override2 unexposed |
| Window Corners visual | LIMITATION — sample-app chrome not claimed without logout/reopen cycle |
| Support prompt + URL | PASS — browser-only; OSG/Kamyab attribution |
| Preview Razorpay | PASS (safe) — `TWEAKSMITH_PAYMENTS_ENABLED=false`; create-order **503** `payments_unavailable`; no unsigned ZIP on page |
| Production Razorpay | PASS (off) — `/api/tweaksmith/create-order` **404** on `kamyab.co.in` |
| Official website (prod) | LIMITATION — `https://kamyab.co.in/tweaksmith` **404** until site deploy; preview “coming soon” (no releases/download) |
| Signed official binary | BLOCKED — 0 Developer ID identities; no notary Keychain profile |
| Production payments | NOT enabled (correct; not a release blocker) |

## Artifact (unsigned RC only)

| Item | Value |
|------|--------|
| App zip | `dist/Tweaksmith-0.1.0-rc.1-macos-arm64-UNSIGNED-NOT-FOR-GATEKEEPER.zip` |
| SHA-256 (app zip) | `f3af9bd57640f3de704b8bdb2de91507a703eb807dbf18962276aa53d9e51505` |
| Signing | `unsigned-adhoc` |
| Notarized | no |
| Gatekeeper public OK | no |
| Draft release | https://github.com/OpenSourceGroup/tweaksmith/releases/tag/untagged-41150195228ac06dbe05 (draft, unpublished) |

## Known limitations

1. No full Xcode.app / XCTest / Developer ID / notarization on this host
2. Override2 absent — not in UI
3. Window Corners visual effect may need quit apps / logout / restart
4. Preview payments disabled until optional TEST keys + flag
5. Unsigned draft only — not Gatekeeper channel
6. Production product pages not deployed yet (404)
7. GST/invoice for support: undefined for v0.1

## Blockers for public “official” v0.1.0 READY

1. Install full **Xcode.app** from the Mac App Store (current stable **Xcode 27.2**), open once to finish components, then:
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -license accept
   xcodebuild -runFirstLaunch
   ```
2. Import **Developer ID Application** identity into Keychain (Xcode → Settings → Accounts → Manage Certificates)
3. Configure **notarytool** Keychain profile (never commit); sign → notarize Accepted → staple → `spctl` assess
4. Clean-install test of stapled artifact
5. Supersede unsigned draft assets; human publish GitHub Release; flip website `download` from `#download` to prepared OSG v0.1.0 URL
6. Deploy production `kamyab.co.in/tweaksmith` when ready — keep payments off until approved

## Re-run

```bash
./scripts/release.sh 0.1.0
```
