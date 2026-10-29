# Roadmap

Buckets align with GitHub labels: `now`, `next`, `later`, `experimental`, `wont-build`. Full board map: [`PROJECT_BOARD.md`](PROJECT_BOARD.md).

**Tagline:** Make your Mac yours.

---

## v0.1 scope (first release)

Ship when release gate returns `READY` or `READY WITH KNOWN LIMITATIONS`:

| Area | Deliverable |
|------|-------------|
| **Settings Engine** | Full lifecycle + history + restore modes |
| **Window Corners** | Module on Tahoe 26+ Apple Silicon |
| **Support UX** | Voluntary support, browser-only links, local counters |
| **Website** | Download + support pages on kamyab.co.in |

Target tag: `0.1.0-rc.1` → gate → `0.1.0`

---

## Now

- Settings Engine core (READ/BACKUP/APPLY/VERIFY/HISTORY/RESTORE/RESET/COMPATIBILITY/ERROR)
- Window Corners module + compatibility gating
- Support UX (no `?paid=true` handling)
- CI with isolated preference domains
- Docs: PRODUCT_PRINCIPLES, ARCHITECTURE, RELEASE_GATE, DEVELOPMENT

---

## Next

- Additional appearance modules (menu bar, accent) after maintainer approval
- Improved external-change detection UX
- Intel-specific compatibility pass
- Localized strings beyond English
- In-app module marketplace **not planned** — keep OSS modular toggles only

---

## Later

- Small, shippable “discovery” modules when demand is clear
- Export/import backup bundles (local files, encrypted optional)
- Shortcuts / AppleScript hooks for restore actions (if safe)

---

## Experimental

- Preview toggles without apply (requires engine support)
- Community module API **only if** sandboxed and reviewable — no timeline

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
| 0.1.x | Engine + Window Corners + Support |
| 0.2.x | Second module wave |
| 1.0 | Stable module set + notarized stable channel |

Dates are not commitments — priority is safety and reversibility over speed.
