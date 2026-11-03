# Internal test matrix

Reusable table for DP2 / future preview installs. Fill only verified cells. Leave blank when untested. Do not invent results.

Target: **3–5 real Macs** for internal testing (doc target only).

**Version column format:** record marketing and build separately, e.g. `26.4` + build `26B123` via `sw_vers -productVersion` and `sw_vers -buildVersion`. Do not merge unlike version families into one string.

| Machine | Chip | macOS | Clean Install | Gatekeeper | Finder | Safari | System Settings | 3rd-party | Apply | Restore Previous | Restore Original | Reset | Notes |
|---------|------|-------|---------------|------------|--------|--------|-----------------|-----------|-------|------------------|------------------|-------|-------|
| MacBook Pro (Mac17,8) — maintainer | Apple M5 Pro (arm64) | **RE-VERIFY** — prior label `27.2 (26B123)` mixed marketing vs build prefixes | | Open Anyway expected (unsigned) | | | | | Prefs write/read-back PASS (Sharp/Subtle) | PASS | PASS | PASS (key absent then baseline restored) | Engine + smoke PASS 2026-10-30; re-run `sw_vers` + About screen OS line after hardening PR. Chrome visual **not claimed** without logout cycle. See `COMPATIBILITY.md`. |
| | | | | | | | | | | | | | |
| | | | | | | | | | | | | | |
| | | | | | | | | | | | | | |
| | | | | | | | | | | | | | |

## Column guide

- **Clean Install** — fresh extract of GitHub DP zip (not a prior local build).
- **Gatekeeper** — result of open / Open Anyway; never disable Gatekeeper or SIP.
- **Finder / Safari / System Settings / 3rd-party** — visible chrome after Apply (often needs quit apps / logout).
- **Apply / Restore Previous / Restore Original / Reset** — in-app Window Corners paths.

Procedure: [`INTERNAL_TESTING.md`](INTERNAL_TESTING.md).

## Manual matrix for Ankit (Apple Silicon)

Run on **2–4 additional Macs** when available. Use the GitHub pre-release zip. Leave cells blank until verified.

| macOS marketing | Build (optional) | Apply blocked (26.3) | Apply + read-back | Restore Previous | Restore Original | Reset default | Electron app (e.g. VS Code) | Native app chrome (Finder) | Notes |
|-----------------|------------------|----------------------|-------------------|------------------|------------------|---------------|-------------------------------|----------------------------|-------|
| **26.3** | | Expect **blocked** in UI; no `NSConvolutionOverride1` write | | | | | | | Fail-closed gate |
| **26.4** | | Expect allowed | | | | | Expect **no effect** / ignore | May need logout | Minimum supported |
| **27.x** | | Expect allowed | | | | | Expect ignore | Compare default radius vs 26.x after Reset | macOS 27 default may differ |

Steps per row:

1. About → confirm OS line matches `sw_vers`.
2. Window Corners → confirm compatibility banner only on 26.3 (or older).
3. Apply Subtle (8) → verify read-back in Changes / `defaults read` if comfortable.
4. Restore Previous → Restore Original → Reset to macOS Default.
5. Note whether Electron vs native apps reflect the preference after logout.
