# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.1.x | Yes (when released) |
| Pre-release RC | Best effort |

## Reporting a vulnerability

Email **security@kamyab.co.in** (or **privacy@kamyab.co.in** for privacy-related reports).

Please include:

- Description and impact
- Steps to reproduce
- macOS version and hardware
- Tweaksmith version or commit SHA

Do **not** open public issues for exploitable vulnerabilities.

We aim to acknowledge within **5 business days** (IST). Coordinated disclosure is preferred.

## Scope

In scope:

- Tweaksmith application and official release artifacts from Kamyab Infotech
- This repository’s GitHub Actions workflows (secrets handling, artifact integrity)

Out of scope:

- macOS platform bugs (report to Apple)
- Third-party forks not built by Kamyab
- Social engineering

## Safe harbor

We do not pursue legal action against researchers who follow this policy and avoid privacy violations, data destruction, or service disruption.

## Product security principles

Tweaksmith does not ship telemetry or remote control. Preference changes are local and reversible via the Settings Engine. We do not instruct users to disable SIP or Gatekeeper.

Official site: [kamyab.co.in](https://kamyab.co.in).
