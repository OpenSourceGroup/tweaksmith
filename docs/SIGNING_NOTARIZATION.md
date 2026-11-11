# Developer ID signing and notarization (Stable v0.1.0)

Stable channel artifacts **must** be Developer ID signed, notarized, stapled, and pass `spctl --assess`. Unsigned or ad-hoc builds are **not** Stable and **not** Gatekeeper-ready. See [issue #1](https://github.com/OpenSourceGroup/tweaksmith/issues/1).

## Repository automation (no secrets in git)

| Script / workflow | Behavior |
|-------------------|----------|
| `scripts/package-release.sh` | Signs when certificate env/keychain identity exists; notarizes when `APPLE_*` secrets present; **exits 1** on plain Stable semver without full notarization |
| `scripts/validate-release-artifact.sh` | Reads `dist/ARTIFACT_META.txt`; enforces `spctl`/stapler when `TWEAKSMITH_REQUIRE_GATEKEEPER=yes` |
| `.github/workflows/release.yml` | Production Stable: requires `gatekeeper_public_ok=yes`, rejects `*-UNSIGNED-NOT-FOR-GATEKEEPER*` zips |
| `.github/workflows/release-candidate.yml` | RC may be unsigned (draft); runs XCTest when Xcode present |
| `.github/workflows/ci.yml` | `packaging-dry-run` job proves unsigned CI artifacts are explicitly labeled |

## GitHub Actions secrets (owner configures)

Configure in the repository **Settings → Secrets and variables → Actions** (and `production` environment for Stable releases). **Never commit values.**

| Secret | Purpose |
|--------|---------|
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded `.p12` **Developer ID Application** certificate export |
| `APPLE_CERTIFICATE_PASSWORD` | Password for the `.p12` import |
| `APPLE_ID` | Apple ID email used with App Store Connect / notarytool |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password for notarytool (not the Apple ID password) |
| `APPLE_TEAM_ID` | 10-character Team ID |

### Owner-only prerequisites (outside this repo)

1. **Apple Developer Program** enrollment for Kamyab Infotech (paid membership).
2. Create **Developer ID Application** certificate in Apple Developer portal; export as `.p12` for CI.
3. Create app-specific password for notarization.
4. Add secrets above to GitHub; re-run **Release Candidate** then **Release** workflows with manual approval.

### Local maintainer verify (after secrets exist)

```bash
export APPLE_CERTIFICATE_BASE64=...  # or use login keychain identity
export APPLE_CERTIFICATE_PASSWORD=...
export APPLE_ID=...
export APPLE_APP_SPECIFIC_PASSWORD=...
export APPLE_TEAM_ID=...
./scripts/package-release.sh 0.1.0-rc.2
TWEAKSMITH_REQUIRE_GATEKEEPER=yes ./scripts/validate-release-artifact.sh
```

Stable:

```bash
TWEAKSMITH_REQUIRE_GATEKEEPER=yes ./scripts/package-release.sh 0.1.0
```

## Acceptance mapping (issue #1)

| Criterion | Automated check |
|-----------|-----------------|
| Developer ID sign | `ARTIFACT_META signing_mode=developer-id` |
| Notarization Accepted | `notarytool --wait` exit 0 in `package-release.sh` |
| Stapled | `stapler staple` + `validate-release-artifact.sh` stapler validate |
| `spctl --assess` | `package-release.sh` and `validate-release-artifact.sh` |
| Stable tag | `release.yml` refuses `gatekeeper_public_ok=no` |

Until secrets exist, CI only proves **unsigned** packaging (`packaging-dry-run`) and unit/smoke tests — not Gatekeeper distribution.
