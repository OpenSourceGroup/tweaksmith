# Release channels

Tweaksmith ships on distinct channels. Do not conflate them.

| Channel | Tag pattern | Requirements |
|---------|-------------|--------------|
| **Developer Preview** | `v0.1.0-dev.N` | Unsigned/ad-hoc OK. GitHub **pre-release**. Technical users; Open Anyway path. |
| **Beta** (optional) | `v0.1.0-beta.N` | Signed preferred. Still not Stable. |
| **Stable** | `v0.1.0`, `v0.1.x` | Developer ID signed, notarized, stapled, Gatekeeper `spctl` accept, release gate **READY** (or READY WITH KNOWN LIMITATIONS). |

## Current

- DP1 = `v0.1.0-dev.1`
- DP2 = `v0.1.0-dev.2`
- Plain `v0.1.0` is reserved for future Stable

## Binary immutability

Never silently replace released binaries or checksums on an existing tag/release.

Next fix after DP2 = **`v0.1.0-dev.3`** with a new SHA-256. Update docs and release notes to point at the new tag.
