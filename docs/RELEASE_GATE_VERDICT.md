# Release Gate Verdict — v0.1 RC

**Date:** 2026-10-29  
**Evaluator:** Bootstrap engineering agent (independent checklist against `docs/RELEASE_GATE.md`)  
**Candidate:** Tweaksmith 0.1.0-rc.1

## Verdict

**READY WITH KNOWN LIMITATIONS**

## Evidence summary

| Area | Result |
|------|--------|
| Settings Engine lifecycle | PASS — smoke tests cover READ/BACKUP/APPLY/VERIFY/RESTORE/RESET/external/compatibility |
| Window Corners module | PASS with limitations — Override1 validated; Override2 not exposed |
| Support prompt logic | PASS — first-launch suppress, ≥3 actions, 30-day wait, max 3, dont-ask, manual open |
| Isolated prefs in tests | PASS — in-memory + suite domains; global writes forbidden in CI backend |
| Native UI shell | PASS (source) — sidebar sections present; GUI not signed/notarized on this host |
| Website / Razorpay | PARTIAL — pages + TEST API staged; secrets not deployed; live payments not cut over |
| CI / GitHub | PARTIAL — workflows present; first push pending Actions run on macos-15 |
| Signed official binary | BLOCKED for public “official” download — no Apple signing/notarize secrets on host |

## Known limitations (accepted for RC)

1. **No full Xcode.app** on bootstrap host — app UI compiles via SPM sources; packaging `.app` + notarization deferred. Use Xcode on a signing Mac for official builds.
2. **`NSConvolutionOverride2`** absent on validation host — not exposed in UI (correct).
3. **Undocumented preference** — Window Corners risk MEDIUM; restart/log-out may be required; preview is illustrative only.
4. **Razorpay TEST only** — production secrets and webhook cut-over need human approval (`docs` on kamyab site: `TWEAKSMITH_SUPPORT.md`).
5. **GitHub Project board** not created — token lacks `project` scope; create manually.
6. **Branch protection** applied soft; CI check name must match after first green run.

## Blockers for public v0.1 “official” release (not RC)

- Install Xcode, archive, sign, notarize; attach checksums to GitHub Release
- Confirm Window Corners on clean macOS Tahoe 26+ volume
- Staging Razorpay TEST end-to-end, then optional LIVE
- Human RELEASE_GATE re-run after notarized artifact exists

## Commands to re-run

```bash
cd tweaksmith
./scripts/run-smoke.sh
./scripts/release-gate.sh
```
