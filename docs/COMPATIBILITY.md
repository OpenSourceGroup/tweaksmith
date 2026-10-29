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

## Window Corners module

### NSConvolutionOverride1

Window corner rounding on recent macOS releases interacts with system rendering pipelines. Tweaksmith’s Window Corners module may write preferences related to **convolution / corner override** behavior (internally referenced as **NSConvolutionOverride1** in engineering docs).

| Topic | Notes |
|-------|--------|
| **Documentation** | Preference may be semi-documented; treat as **MEDIUM** risk |
| **Revert** | Always available via Settings Engine restore paths |
| **Restart** | Full logout or restart may be required for visual effect to apply or revert—UI must state this before apply |
| **External drift** | macOS updates or other tools may change values; external change detection applies |

### Visual verification

Validate on:

- Light and dark appearance
- Multiple displays (if available)
- Stage Manager on/off if user reports conflicts (document in release notes)

---

## Undocumented preference keys

Any key not listed in Apple’s public documentation is **HIGH** or **UNVERIFIED** risk until validated on a test VM.

Policy:

- Document key name and observed behavior in module spec
- Default module compatibility badge to MEDIUM or HIGH
- Block **Apply** on unsupported OS branches via `CompatibilityService`

---

## Settings domains

Writing to global domains affects the whole user session. Tweaksmith:

- Backs up before first write
- Never writes from CI/tests to production domains
- Lists affected domains in module detail UI

---

## Restart & session notes

| Action | Typical requirement |
|--------|---------------------|
| Window Corners apply/revert | Often requires **logout** or **restart** |
| Minor `defaults` toggles | Sometimes immediate; still verify with READ |
| macOS point release upgrade | Re-run compatibility; user may need Restore All |

Always prefer honest copy over promising instant changes.

---

## Forbidden environments

Not supported—issues may be closed as `wont-build`:

- SIP disabled
- Gatekeeper disabled globally
- Modified system frameworks
- kext-dependent tools

---

## Reporting compatibility issues

Use GitHub issue template **Compatibility** with macOS version, chip, module name, and whether restore fixed the issue.

Official site: [kamyab.co.in](https://kamyab.co.in) (never kamyab.in).
