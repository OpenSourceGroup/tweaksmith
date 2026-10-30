# Internal test matrix

Reusable table for DP2 / future preview installs. Fill only verified cells. Leave blank when untested. Do not invent results.

Target: **3–5 real Macs** for internal testing (doc target only).

| Machine | Chip | macOS | Clean Install | Gatekeeper | Finder | Safari | System Settings | 3rd-party | Apply | Restore Previous | Restore Original | Reset | Notes |
|---------|------|-------|---------------|------------|--------|--------|-----------------|-----------|-------|------------------|------------------|-------|-------|
| MacBook Pro (Mac17,8) — maintainer | Apple M5 Pro (arm64) | 27.2 (26B123) | | Open Anyway expected (unsigned) | | | | | Prefs write/read-back PASS (Sharp/Subtle) | PASS | PASS | PASS (key absent then baseline restored) | Engine + smoke PASS 2026-10-30; sample-app chrome visual **not claimed** without logout cycle. See `COMPATIBILITY.md`. |
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
