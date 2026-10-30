# Tweaksmith Developer Preview 2 — Visual QA (APPROVED)

**Status:** `DEVELOPER PREVIEW 2 — VISUAL APPROVED` (publish path)  
**Stable:** BLOCKED — Developer ID / notarization deferred.

Release artifact:

- `Tweaksmith-0.1.0-Developer-Preview-2-macOS.zip`
- Tag: `v0.1.0-dev.2` (GitHub pre-release)

## Empty UI — root cause

DP1 presented an empty charcoal sidebar + medium-gray detail.

**Cause (verified via Accessibility + layout geometry):**

1. `NavigationSplitView` content laid out **outside the visible window** (splitter/detail at large negative Y / oversized height ≈1749pt while the window was ~612pt). Backgrounds still painted inside the window → hollow shell.
2. Sidebar `Label` static texts measured **0×0** (AX value present, no visible glyphs).
3. Product shell also listed fake placeholder categories (Finder/Dock/…) instead of the real v0.1 surfaces.

Not a missing `@EnvironmentObject` crash; the scene mounted, but layout + Label metrics failed to paint usable UI.

## Fix

- Three real sidebar destinations only: **Window Corners / Changes / Support** (grouped TWEAKS / ACTIVITY / TWEAKSMITH).
- Default selection **Window Corners**; invalid selection falls back to Window Corners.
- Explicit `Text` + `Image` sidebar rows (avoid 0×0 `Label` paint).
- `ScrollView` detail, `defaultSize(900×620)`, constrained frames (no Spacer-driven height explosion).
- Live window preview, presets, Apply confirmation, Restore & Safety (engine semantics unchanged).
- FORGED CORNER `AppIcon.icns` in Resources + `CFBundleIconFile`.
- Packaging: strip AppleDouble/`xattr` before ad-hoc seal; zip with `COPYFILE_DISABLE` + `ditto --norsrc`.

## Screenshots

| # | Path |
|---|------|
| 1 Window Corners dark | `docs/screenshots/01-window-corners-dark.png` |
| 2 Window Corners light | `docs/screenshots/02-window-corners-light.png` |
| 3 Changes | `docs/screenshots/03-changes.png` |
| 4 Support | `docs/screenshots/04-support.png` |
| 5 About | `docs/screenshots/05-about.png` |
| 6 Icon | `docs/screenshots/06-finder-dock-icon.png` (+ `06-appicon-1024.png`) |

Captured via AppKit `cacheDisplay` (no Screen Recording / Gatekeeper bypass).

## Gatekeeper diagnosis (DP1 GitHub artifact)

Artifact: `~/Downloads/Tweaksmith-0.1.0-Developer-Preview-macOS.zip`  
SHA-256: `de9e3c6ed0468424d613cf1665dcd7f8a140c45db9e31da2f99e449d0d253f70`  
Source: GitHub Releases DP1 (now tagged `v0.1.0-dev.1`; quarantine present from Chrome download; inspected only).

| Check | Result |
|-------|--------|
| Arch | arm64 Mach-O |
| Signature | **adhoc** (`flags=0x2`), TeamIdentifier not set |
| Clean extract (`ditto --norsrc` / strip `._*`) | `codesign --verify --deep --strict` **valid**; `spctl` **rejected** (expected for unsigned) |
| Extract retaining AppleDouble `._*` from zip | sealed resource invalid / `spctl` internal error |

**Classification: EXPECTED UNSIGNED PREVIEW — Open Anyway path OK**

Secondary packaging note (fixed for DP2 local builds): DP1 zip embedded AppleDouble `._*` entries that can break sealed-resource verify on some extract paths. Not XProtect malware; not Developer ID damage.

## Tests

- XCTest: 12/12 pass (`SettingsEngineTests` + `SupportPromptTests`)
- Smoke: ALL PASS
- Debug + Release SwiftPM builds: pass

## Release

Visual direction **APPROVED**. Publish as unsigned GitHub **Pre-release** `v0.1.0-dev.2`.

### `DEVELOPER PREVIEW 2 — RELEASED` (after GitHub publish)

### Stable: BLOCKED — DEVELOPER ID / NOTARIZATION DEFERRED
