# Tweaksmith

**Make your Mac yours.**

Free, open-source, native macOS tweaks—modular, reversible, and private. Built with Swift and SwiftUI by [Kamyab Infotech](https://kamyab.co.in).

---

## Principles

- **Free & OSS (MIT)** — no locked features, no accounts, no ads, no telemetry
- **Native** — Apple Silicon first; macOS **Tahoe 26+**
- **Reversible** — Settings Engine backup, history, and restore
- **Safe** — no SIP disable, no Gatekeeper disable, no kernel extensions
- **Voluntary support** — pay-what-it’s-worth never unlocks features

Read the full contract: [`docs/PRODUCT_PRINCIPLES.md`](docs/PRODUCT_PRINCIPLES.md).

---

## Status

Bootstrap documentation and GitHub ops are in place. Application source lands separately under this tree.

**v0.1 target:** Settings Engine + Window Corners + Support UX + website support pages.

---

## Quick links

| Doc | Purpose |
|-----|---------|
| [Architecture](docs/ARCHITECTURE.md) | App structure & Settings Engine |
| [Compatibility](docs/COMPATIBILITY.md) | OS support & Window Corners notes |
| [Roadmap](docs/ROADMAP.md) | NOW / NEXT / LATER buckets |
| [Contributing](CONTRIBUTING.md) | PR flow & tests |
| [Security](SECURITY.md) | Vulnerability reporting |
| [Release process](docs/RELEASE_PROCESS.md) | RC → gate → production |

---

## Development

```bash
./scripts/bootstrap-check.sh
./scripts/release-gate.sh   # human checklist — see docs/RELEASE_GATE.md
```

When the Xcode project or `Package.swift` exists:

```bash
swift test
# tests must use isolated preference domains — never mutate global runner prefs
```

---

## Research

Grok reports go to `research/inbox/` using [`docs/RESEARCH_AGENT.md`](docs/RESEARCH_AGENT.md). Human validation required before engineering.

---

## License

Code: [MIT](LICENSE). Name and official builds are Kamyab-controlled; see PRODUCT_PRINCIPLES for branding.

---

## Contact

- Website: [kamyab.co.in](https://kamyab.co.in) (never kamyab.in)
- Security: security@kamyab.co.in — see [SECURITY.md](SECURITY.md)
