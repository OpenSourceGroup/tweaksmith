# v0.1.0 Stable release checklist

Use with [`RELEASE_GATE.md`](RELEASE_GATE.md), [`INTERNAL_TEST_MATRIX.md`](INTERNAL_TEST_MATRIX.md), and [`SIGNING_NOTARIZATION.md`](SIGNING_NOTARIZATION.md). **Do not** tag `v0.1.0` until every **Stable blocker** row is checked.

## Automated (macOS CI)

- [ ] PR CI: `test` job — bootstrap, XCTest, smoke, hygiene (no `|| true` bypass)
- [ ] PR CI: `packaging-dry-run` — unsigned zip name contains `UNSIGNED-NOT-FOR-GATEKEEPER`, `gatekeeper_public_ok=no`
- [ ] `CHANGELOG.md` documents user-visible changes since DP2

## Signing / Gatekeeper (issue #1 — owner)

- [ ] `APPLE_*` secrets configured in GitHub Actions
- [ ] Release Candidate workflow produces `gatekeeper_public_ok=yes` **or** documented RC stays draft unsigned
- [ ] Production `release.yml` with `TWEAKSMITH_REQUIRE_GATEKEEPER=yes` completes on a test tag before `v0.1.0`
- [ ] `spctl --assess` and stapler validate on shipped `.app` (see `validate-release-artifact.sh`)

## Manual Mac QA (Ankit / maintainers)

Apple Silicon, real hardware — see manual table in [`INTERNAL_TEST_MATRIX.md`](INTERNAL_TEST_MATRIX.md).

| macOS | Apply | Restore paths | UI compatibility banner (26.3) | Notes |
|-------|-------|---------------|----------------------------------|-------|
| 26.3 | Blocked, no write | N/A for apply | Banner + disabled Apply | |
| 26.4 | Allowed, read-back | Previous / Original / Reset | No banner | Logout for chrome optional |
| 27.x | Allowed | Same | No banner | Electron ignore; default radius note |

Also verify About → OS line matches `sw_vers -productVersion` and `-buildVersion`.

## Support payments (website — parallel to PR #4)

- [ ] Razorpay **Live** on kamyab.co.in checkout (not in this repo)
- [ ] End-to-end: app → browser support page → small live payment
- [ ] See [`SUPPORT_PAYMENTS.md`](SUPPORT_PAYMENTS.md)

## Documentation / comms

- [ ] `RELEASE_GATE_VERDICT.md` updated to READY or READY WITH KNOWN LIMITATIONS
- [ ] GitHub Release notes + SHA-256 published
- [ ] Website download points at Stable **only** when Gatekeeper-ready

## Explicitly not Stable until signed

Developer Preview tags (`v0.1.0-dev.N`), unsigned RC zips, and CI dry-run artifacts are **not** Stable and require **Open Anyway** or technical-user paths.
