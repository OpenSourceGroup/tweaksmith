# Tweaksmith — Product Principles

**Tagline:** Make your Mac yours.

Tweaksmith is a free, open-source, native macOS application built with Swift and SwiftUI. It helps people tune appearance and behavior through reversible, modular tweaks—without compromising safety, privacy, or system integrity.

**An Open Source Group project.** Maintained by **Kamyab Infotech** ([kamyab.co.in](https://kamyab.co.in)). Official builds are published by the maintainer. Source code is licensed under MIT. Copyright in `LICENSE` stays Kamyab Infotech Private Limited until a legal owner decides otherwise.

---

## Non-negotiables

| Principle | Commitment |
|-----------|------------|
| **Free & OSS** | No paywalls, no feature locks, no “Pro” tiers that hide capability |
| **Native** | Swift/SwiftUI; feels and behaves like a Mac app |
| **Modular** | Features ship as modules; enable only what you use |
| **Reversible** | Every change has a clear undo path (history, restore, reset) |
| **Privacy** | No telemetry, no ads, no accounts, no phone-home analytics |
| **Voluntary support** | Optional payments are processed by Kamyab Infotech Pvt Ltd, the project's maintainer, and **never** unlock features |
| **Safety** | No SIP disable, no Gatekeeper disable, no kernel extensions |
| **Platform** | macOS **Tahoe 26+**; **Apple Silicon first** (Intel best-effort where feasible) |
| **Domain** | Official web presence uses **kamyab.co.in** — never kamyab.in |

---

## What we will not build

- Telemetry, crash reporting that sends user data to third parties, or fingerprinting
- Account systems, license servers, or online activation for app features
- Ads, sponsorship slots inside the app, or dark patterns for donations
- Tweaks that require disabling System Integrity Protection (SIP)
- Tweaks that require turning off Gatekeeper globally
- Kernel extensions (kexts) or unsupported private API abuse
- “Unlock” mechanics tied to payment—support is gratitude, not a key

---

## Modularity

Each tweak lives in a **module** with:

- Explicit scope (which preferences or APIs it touches)
- Compatibility metadata (macOS version, chip, known limitations)
- Isolated apply/revert logic routed through the **Settings Engine**

Modules can be disabled without uninstalling the app. Disabled modules must not write preferences or leave partial state.

---

## Reversibility & history

All preference writes go through the Settings Engine lifecycle:

**READ → BACKUP → APPLY → VERIFY → HISTORY → RESTORE → RESET → COMPATIBILITY → ERROR**

Users must always be able to:

- **Restore Previous** — last known good snapshot before the latest apply
- **Restore Original** — state captured at first Tweaksmith backup for that domain
- **Reset to macOS Default** — documented default for that preference domain
- **Restore All** — coordinated rollback across modules (with clear warnings)

External changes (Terminal, other apps, macOS updates) are detected where possible; UI explains drift and offers safe recovery.

---

## Safety & system integrity

- Prefer documented `defaults`, supported appearance APIs, and user-space mechanisms
- Document **undocumented preference keys** as higher risk in COMPATIBILITY.md
- Never instruct users to weaken system security for convenience
- Window Corners and similar features must declare restart/logout requirements honestly
- Fail closed: if verify step fails, do not claim success; offer rollback

---

## Privacy & local-only data

- Support “thank you” counters and optional local stats stay **on device only**
- No export of usage to Kamyab servers unless the user explicitly uses a support URL in their browser
- Support links open in the **system browser only**; the app must **not** treat query parameters such as `?paid=true` as proof of payment or unlock anything

---

## Support model

- **Free forever** for all features in the OSS tree
- **Voluntary pay-what-it’s-worth** via website/donation flows—gratitude, not entitlement
- Community: GitHub issues/discussions; security via SECURITY.md
- Official downloads: Kamyab-signed/notarized builds when release pipeline secrets exist

---

## Branding & builds

- **Code:** MIT (see LICENSE)
- **Name, logo, marketing site:** Kamyab Infotech—downstream forks must not imply official status
- **Official builds:** Produced by Kamyab release workflow; checksums published on GitHub Releases

---

## Engineering alignment

Contributors must read this document before feature work. If a proposal conflicts with any row in **Non-negotiables**, stop and escalate via issue—not implementation.
