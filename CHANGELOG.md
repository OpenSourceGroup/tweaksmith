# Changelog

All notable changes to Tweaksmith are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed
- Public repository is [OpenSourceGroup/tweaksmith](https://github.com/OpenSourceGroup/tweaksmith). Kamyab Infotech remains the lead maintainer.

## [0.1.0] - 2026-10-29

### Added
- Settings Engine: READ / BACKUP / APPLY / VERIFY / RESTORE / RESET lifecycle with isolated-prefs tests
- Window Corners module (Tahoe 26+, Apple Silicon; Override1; Override2 gated when absent)
- Support UX: local counters, browser-only links, voluntary support copy
- Native SwiftUI shell (Overview / Appearance / Support)
- SwiftPM packaging via `scripts/package-release.sh` (`.app` + SHA-256; ad-hoc when unsigned)

### Known limitations
- **Developer Preview** GitHub pre-release is **unsigned** (ad-hoc) — not Developer ID / notarized / Gatekeeper-ready
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

[Unreleased]: https://github.com/OpenSourceGroup/tweaksmith/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/OpenSourceGroup/tweaksmith/releases/tag/v0.1.0
[0.1.0-rc.1]: https://github.com/OpenSourceGroup/tweaksmith/releases/tag/v0.1.0-rc.1
