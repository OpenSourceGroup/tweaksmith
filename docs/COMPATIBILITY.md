# Compatibility

Tweaksmith targets **macOS Tahoe (26)** and later. **Apple Silicon** is the primary test and optimization platform. Intel Macs may run builds where Apple still ships macOS 26; modules may gate features when behavior differs.

---

## Platform matrix

| Environment | Support level |
|-------------|---------------|
| macOS 26+ (Tahoe) | Primary |
| Apple Silicon (M-series) | Primary |
| Intel (macOS 26+) | Best effort; module-level gates |
| macOS 25 and earlier | Not supported |

---

## Evidence — Window Corners (2026-10-29)

Host: macOS **27.2** (Build **26B123**, Tahoe 26 family), **arm64**, Apple **M5 Pro**. Full Xcode.app: **absent** (CLT only). Developer ID identities: **0**.

| Check | Result | Notes |
|-------|--------|--------|
| Key `NSConvolutionOverride1` | Present (float) | Observed baseline **6.0** before QA; restored to **6.0** after |
| Key `NSConvolutionOverride2` | **Absent** | Not exposed in UI |
| Preset write 4 / 8 / 10 | Read-back matches | Via `defaults write -g` |
| Restore previous (write prior value) | PASS | |
| Reset default (delete key) | PASS — key absent | |
| Re-create after absent | PASS | |
| External change (out-of-band write) | Detectable by engine smoke | Smoke: `detect external change` |
| Restart / logout | **Guidance only** | Visual effect may need quit apps / logout / restart; not forced in QA |
| Sample apps visual | Manual / incomplete | Finder, System Settings, Safari, Notes/TextEdit, one 3rd-party, custom-chrome: **logout/restart may be required**; in-app preview is illustrative |
| Isolated-domain smoke | PASS | `./scripts/run-smoke.sh` |

Risk: **MEDIUM** (undocumented preference). Always reversible via Settings Engine restore paths.

---

## Window Corners module

### NSConvolutionOverride1

| Topic | Notes |
|-------|--------|
| **Documentation** | Semi-documented / undocumented — treat as **MEDIUM** risk |
| **Revert** | Restore Previous / Original / Reset to macOS Default |
| **Restart** | Full logout or restart may be required — UI must state this before apply |
| **External drift** | macOS updates or other tools may change values |

### NSConvolutionOverride2

**Not exposed.** Absent on validation host. Do not surface in product UI until independently confirmed.

### Visual verification checklist

- Light and dark appearance
- Multiple displays (if available)
- Stage Manager on/off if user reports conflicts

---

## Undocumented preference keys

Any key not listed in Apple’s public documentation is **HIGH** or **UNVERIFIED** until validated.

Policy:

- Document key name and observed behavior in module spec
- Default module compatibility badge to MEDIUM or HIGH
- Block **Apply** on unsupported OS branches via compatibility gating

---

## Settings domains

Writing to global domains affects the whole user session. Tweaksmith:

- Backs up before first write
- Never writes from CI/tests to production domains
- Lists affected domains in module detail UI
- Verifies read-back after apply; surfaces verification failures (no silent partial apply)

---

## Restart & session notes

| Action | Typical requirement |
|--------|---------------------|
| Window Corners apply/revert | Often requires **logout** or **restart** |
| Minor `defaults` toggles | Sometimes immediate; still verify with READ |
| macOS point release upgrade | Re-run compatibility; user may need Restore All |

---

## Forbidden environments

Not supported — issues may be closed as `wont-build`:

- SIP disabled
- Gatekeeper disabled globally
- Modified system frameworks
- kext-dependent tools

---

## Reporting compatibility issues

Use GitHub issue template **Compatibility** with macOS version, chip, module name, and whether restore fixed the issue.

Official site: [kamyab.co.in](https://kamyab.co.in) (never kamyab.in).
