# Changelog

All notable changes to Tweaksmith are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- (none yet)

## [0.1.0] - 2026-10-29

### Added
- Settings Engine: READ / BACKUP / APPLY / VERIFY / RESTORE / RESET lifecycle with isolated-prefs tests
- Window Corners module (Tahoe 26+, Apple Silicon; Override1; Override2 gated when absent)
- Support UX: local counters, browser-only links, voluntary support copy
- Native SwiftUI shell (Overview / Appearance / Support)
- SwiftPM packaging via `scripts/package-release.sh` (`.app` + SHA-256; ad-hoc when unsigned)

### Known limitations
- Official Gatekeeper distribution requires Developer ID + notarization (secrets/Xcode on signing Mac)
- Window Corners may need logout/restart; preview illustrative only
- Razorpay support path may remain TEST until production cut-over

## [0.1.0-rc.1] - 2026-10-29

### Added
- Repository bootstrap: product docs, GitHub templates, CI/release workflows
- Release candidate packaging path and release-gate verdict process
- Smoke tests for Settings Engine + support prompt logic (CLT-friendly)

### Planned for stable
- Signed/notarized official `.app` when Apple CI secrets exist

[Unreleased]: https://github.com/KamyabInfotech/tweaksmith/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/KamyabInfotech/tweaksmith/releases/tag/v0.1.0
[0.1.0-rc.1]: https://github.com/KamyabInfotech/tweaksmith/releases/tag/v0.1.0-rc.1
