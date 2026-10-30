# Changelog

All notable changes to Tweaksmith are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed
- Public repository is [OpenSourceGroup/tweaksmith](https://github.com/OpenSourceGroup/tweaksmith). Kamyab Infotech remains the lead maintainer.
- DP1 relocated to tag `v0.1.0-dev.1`; plain `v0.1.0` reserved for future Stable
- Internal testing docs, release channels, issue-template hygiene for DP2 freeze

## [0.1.0-dev.2] - 2026-10-30

### Added
- Developer Preview 2 unsigned pre-release packaging (`Tweaksmith-0.1.0-Developer-Preview-2-macOS.zip`)
- FORGED CORNER `AppIcon.icns` + curated product screenshots in README

### Fixed
- Blank UI: Window Corners opens immediately; sidebar Window Corners / Changes / Support only
- Preference backend wrote `.global` keys to the app domain — now uses `CFPreferences` / NSGlobalDomain
- Release ZIP AppleDouble (`._*`) pollution that broke sealed-resource verify on some extracts

### Known limitations
- Unsigned ad-hoc preview — Gatekeeper rejection expected; Open Anyway for technical users
- Stable Gatekeeper v0.1 still blocked on Developer ID + notarization

## [0.1.0-dev.1] - 2026-10-29

### Added
- Settings Engine: READ / BACKUP / APPLY / VERIFY / RESTORE / RESET lifecycle with isolated-prefs tests
- Window Corners module (Tahoe 26+, Apple Silicon; Override1; Override2 gated when absent)
- Support UX: local counters, browser-only links, voluntary support copy
- Native SwiftUI shell (Overview / Appearance / Support)
- SwiftPM packaging via `scripts/package-release.sh` (`.app` + SHA-256; ad-hoc when unsigned)

### Known limitations
- **Developer Preview 1** GitHub pre-release is **unsigned** (ad-hoc) — not Developer ID / notarized / Gatekeeper-ready
- Stable Gatekeeper v0.1 remains blocked until Developer ID + notarization
- Window Corners may need logout/restart; preview illustrative only
- Window Corners adjusts the macOS window-corner preference used by supported applications (no every-app claim; Override2 not exposed)

## [0.1.0-rc.1] - 2026-10-29

### Added
- Repository bootstrap: product docs, GitHub templates, CI/release workflows
- Release candidate packaging path and release-gate verdict process
- Smoke tests for Settings Engine + support prompt logic (CLT-friendly)

### Planned for stable
- Signed/notarized official `.app` when Apple CI secrets exist

[Unreleased]: https://github.com/OpenSourceGroup/tweaksmith/compare/v0.1.0-dev.2...HEAD
[0.1.0-dev.2]: https://github.com/OpenSourceGroup/tweaksmith/releases/tag/v0.1.0-dev.2
[0.1.0-dev.1]: https://github.com/OpenSourceGroup/tweaksmith/releases/tag/v0.1.0-dev.1
[0.1.0-rc.1]: https://github.com/OpenSourceGroup/tweaksmith/releases/tag/v0.1.0-rc.1
