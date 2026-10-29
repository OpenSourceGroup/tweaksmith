# Tweaksmith Architecture

Native macOS application structure for Tahoe 26+, Apple Silicon first. All preference mutations flow through **Settings Engine**; features remain thin modules.

---

## Layer overview

```
TweaksmithApp (SwiftUI App)
├── Core/
│   ├── SettingsEngine/     # READ/BACKUP/APPLY/VERIFY/HISTORY/RESTORE/RESET/COMPATIBILITY/ERROR
│   ├── Preferences/        # Domain models, typed keys, sandboxed test stores
│   ├── Compatibility/      # OS version, chip, module gates
│   ├── History/            # Local audit + snapshots metadata
│   ├── Support/            # Browser-only URLs, local counters
│   └── Modules/            # Module registry, enable/disable, dependencies
├── Features/
│   ├── SettingsEngineUI/   # Engine status, rollback UX
│   ├── WindowCorners/      # Corner radius / convolution override module
│   └── SupportUX/          # Voluntary support surfaces
├── DesignSystem/           # Typography, colors, components (Kamyab-aligned, app-owned)
└── Resources/              # Assets, localized strings, default plist templates
```

---

## App entry

- `@main` SwiftUI `App` wires environment objects: `SettingsEngine`, `ModuleRegistry`, `CompatibilityService`
- Scene: primary window + optional settings; no login scene
- Deep links: none required v0.1; support links exit to browser

---

## Settings Engine

Single write path for production code:

1. **READ** — `defaults read` equivalent via typed wrapper (or mock in tests)
2. **BACKUP** — First-touch snapshot stored under app container (per domain/key)
3. **APPLY** — Write only after backup exists unless explicit “ephemeral preview” mode (dev only)
4. **VERIFY** — Read-back; mismatch → ERROR + rollback offer
5. **HISTORY** — Append-only local log (timestamp, module, domain, old/new, result)
6. **RESTORE** — Modes:
   - *Restore Previous* — undo last apply
   - *Restore Original* — first Tweaksmith backup
   - *Reset to macOS Default* — shipped default table per key
   - *Restore All* — ordered rollback across modules (reverse dependency order)
7. **RESET** — Module-specific domain cleanup
8. **COMPATIBILITY** — Block apply when `CompatibilityService` reports unsupported
9. **ERROR** — User-visible failure; no silent writes

### External change detection

Periodic or on-focus **READ** compares live system value to last known applied value. If drift detected:

- Show non-blocking banner with “Restore Tweaksmith value” / “Accept external value” / “Open History”

---

## Preferences layer

- Typed keys grouped by **domain** (e.g. `NSGlobalDomain`, module-specific suites)
- **Test stores:** `PreferencesStoreProtocol` with `InMemoryPreferencesStore` and `IsolatedDomainPreferencesStore` for CI
- **Never** in tests: writing to real user global domains on the runner

---

## Modules

Each module implements:

- `ModuleDescriptor` (id, display name, compatibility)
- `apply()` / `revert()` delegating to Settings Engine
- Optional UI in `Features/`

**Window Corners** uses documented/semidocumented keys (see COMPATIBILITY.md) for corner rendering overrides.

---

## Support subsystem

- `SupportService` holds local-only integers (e.g. times user opened support page)
- Opens `URL` via system browser; does not parse return URLs
- No authentication tokens

---

## DesignSystem

Shared SwiftUI components: buttons, toggles, module cards, risk badges (LOW/MEDIUM/HIGH). Keeps Features free of one-off styling.

---

## Resources

- Asset catalog (icons, accent colors)
- `Localizable.strings` for user-visible copy
- Default value plists for **Reset to macOS Default**

---

## Build & test (target)

- Xcode project or Swift Package as app grows
- Unit tests: Engine + Preferences with isolated domains
- UI tests: optional; must not mutate global prefs
- CI: `.github/workflows/ci.yml`

---

## Security boundaries

- App Sandbox as appropriate for distribution
- No entitlement requests that imply SIP bypass
- Secrets only in CI environments—not in repo

See also: `PRODUCT_PRINCIPLES.md`, `COMPATIBILITY.md`.
