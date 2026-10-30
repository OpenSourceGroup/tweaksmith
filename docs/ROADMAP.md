# Roadmap

Buckets align with GitHub labels: `now`, `next`, `later`, `experimental`, `wont-build`. Full board map: [`PROJECT_BOARD.md`](PROJECT_BOARD.md).

**Tagline:** Make your Mac yours.

**Freeze:** Developer Preview 2 is **frozen for internal testing**. No new product features, v0.2 scope, UI redesign, or payment redesign until Stable signing unblocks or maintainers lift the freeze. Channels: [`RELEASE_CHANNELS.md`](RELEASE_CHANNELS.md).

Internal tester target: **3–5 real Macs** — see [`INTERNAL_TEST_MATRIX.md`](INTERNAL_TEST_MATRIX.md).

---

## v0.1 scope (first Stable)

Ship when release gate returns `READY` or `READY WITH KNOWN LIMITATIONS` **and** Developer ID + notarization complete:

| Area | Deliverable |
|------|-------------|
| **Settings Engine** | Full lifecycle + history + restore modes |
| **Window Corners** | Module on Tahoe 26+ Apple Silicon |
| **Support UX** | Voluntary support, browser-only links, local counters |
| **Website** | Download + support pages on kamyab.co.in |

Preview tags: `v0.1.0-dev.1` (DP1), `v0.1.0-dev.2` (DP2). Stable tag: plain `v0.1.0` (reserved).

---

## Now

- Internal DP2 testing (matrix + procedure)
- Sign / notarize backlog for Stable Gatekeeper v0.1
- Docs and release-channel hygiene only

---

## Under consideration

Broad backlog only — not committed for this freeze:

- Additional appearance modules (menu bar, accent) after maintainer approval
- Improved external-change detection UX
- Intel-specific compatibility pass
- Localized strings beyond English
- Small “discovery” modules when demand is clear
- Export/import backup bundles (local files, encrypted optional)
- Shortcuts / AppleScript hooks for restore actions (if safe)
- Preview toggles without apply (experimental)
- Community module API **only if** sandboxed and reviewable — no timeline

In-app module marketplace **not planned** — keep OSS modular toggles only.

---

## Wont build

- Telemetry, ads, accounts, license keys
- Paid feature unlocks
- SIP/Gatekeeper disable flows
- kexts or kernel patches
- Cloud sync of preferences
- Anything that phones home without explicit browser action by user

---

## Version sketch

| Version | Theme |
|---------|--------|
| 0.1.0-dev.N | Developer Preview (unsigned OK) |
| 0.1.x Stable | Engine + Window Corners + Support (signed/notarized) |
| Later | Second module wave — after freeze lift |
| 1.0 | Stable module set + notarized stable channel |

Dates are not commitments — priority is safety and reversibility over speed.
