# Internal testing procedure (Developer Preview 2)

Use the published GitHub pre-release — not a local `dist/` rebuild — unless you are packaging QA.

**Do not** disable Gatekeeper or SIP. **Do not** run `spctl --master-disable` or strip quarantine as the normal install path.

## Steps

1. Download DP2 from [GitHub Pre-release `v0.1.0-dev.2`](https://github.com/OpenSourceGroup/tweaksmith/releases/tag/v0.1.0-dev.2): `Tweaksmith-0.1.0-Developer-Preview-2-macOS.zip`
2. Verify SHA-256 against `Tweaksmith-0.1.0-Developer-Preview-2-macOS.sha256`
3. Extract the `.app` (optional: move to `/Applications`)
4. Launch Tweaksmith
5. If blocked: **System Settings → Privacy & Security → Open Anyway**
6. Confirm app icon and UI (Window Corners / Changes / Support)
7. Note starting Window Corners state (System Default / current value)
8. Apply **Sharp**, then **Subtle** — confirm read-back / Changes entry
9. **Restore Previous** — confirm prior value
10. **Restore Original** — confirm original backup value
11. Apply a preset again, then **Reset** to macOS Default
12. Quit and relaunch — confirm UI and state
13. Spot-check chrome after apply: Finder, Safari, System Settings, one 3rd-party app, any custom-rendered window you care about (logout/restart of apps may be required)
14. Open **Support** — voluntary page in browser; payment never required
15. Record results in [`INTERNAL_TEST_MATRIX.md`](INTERNAL_TEST_MATRIX.md)

## Failures

File a [Bug report](https://github.com/OpenSourceGroup/tweaksmith/issues/new?template=bug_report.yml) or [Compatibility report](https://github.com/OpenSourceGroup/tweaksmith/issues/new?template=compatibility.yml). Redact serial numbers, Apple ID, and personal paths.
