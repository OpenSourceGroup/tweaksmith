# Release Gate — Independent QA Checklist

Run before tagging a release candidate or shipping to production. The gate returns **exactly one** verdict:

- `READY`
- `READY WITH KNOWN LIMITATIONS`
- `BLOCKED`

Record the verdict in the release issue/PR and `CHANGELOG.md`. Script stub: `scripts/release-gate.sh`.

---

## Gate rules

- Any **BLOCKED** criterion → entire release is **BLOCKED**
- **KNOWN LIMITATIONS** must be documented in `docs/COMPATIBILITY.md` and release notes
- CI must be green on the commit being released (or waived only by maintainer with written reason)

---

## 1. Settings Engine

| # | Criterion | Pass |
|---|-----------|------|
| 1.1 | READ/BACKUP/APPLY/VERIFY path works on clean test account | ☐ |
| 1.2 | Failed VERIFY does not leave UI showing success | ☐ |
| 1.3 | HISTORY records local audit trail | ☐ |
| 1.4 | Restore Previous restores pre-last-apply state | ☐ |
| 1.5 | Restore Original restores first-backup state | ☐ |
| 1.6 | Reset to macOS Default documented per module | ☐ |
| 1.7 | Restore All orchestrates without orphan domains | ☐ |
| 1.8 | ERROR states offer rollback or support link | ☐ |
| 1.9 | Tests use **isolated preference domains** only | ☐ |

---

## 2. Window Corners module

| # | Criterion | Pass |
|---|-----------|------|
| 2.1 | Apply/revert on Tahoe 26+ Apple Silicon test host | ☐ |
| 2.2 | NSConvolutionOverride1 behavior matches COMPATIBILITY.md | ☐ |
| 2.3 | Restart/logout requirements shown before apply | ☐ |
| 2.4 | Module disable stops further writes | ☐ |

---

## 3. Support UX

| # | Criterion | Pass |
|---|-----------|------|
| 3.1 | Support URL opens in **browser only** | ☐ |
| 3.2 | App ignores `?paid=true` and similar params | ☐ |
| 3.3 | Counters stored locally only; no network | ☐ |
| 3.4 | Copy reflects voluntary support, no feature unlock | ☐ |

---

## 4. CI & repository hygiene

| # | Criterion | Pass |
|---|-----------|------|
| 4.1 | `ci.yml` green on release commit | ☐ |
| 4.2 | No secrets in repo, logs, or release artifacts | ☐ |
| 4.3 | `bootstrap-check.sh` passes | ☐ |
| 4.4 | LICENSE, SECURITY, PRODUCT_PRINCIPLES unchanged in spirit | ☐ |

---

## 5. Compatibility & docs

| # | Criterion | Pass |
|---|-----------|------|
| 5.1 | `COMPATIBILITY.md` updated for new keys/behaviors | ☐ |
| 5.2 | Known limitations listed with workarounds | ☐ |
| 5.3 | README tagline and principles accurate | ☐ |

---

## 6. Release artifacts (RC and final)

| # | Criterion | Pass |
|---|-----------|------|
| 6.1 | Version matches git tag and CHANGELOG section | ☐ |
| 6.2 | Checksums published for official binaries | ☐ |
| 6.3 | Notarization stapled when signing secrets configured | ☐ |
| 6.4 | GitHub Release notes include limitation summary if any | ☐ |

---

## Verdict worksheet

```
Release version: ___________
Commit SHA: ___________
Tester: ___________
Date: ___________

BLOCKED items (if any): ___________
KNOWN LIMITATIONS summary: ___________

VERDICT (circle one):  READY  |  READY WITH KNOWN LIMITATIONS  |  BLOCKED
```

**Only one verdict.** If BLOCKED, do not tag production. RC may be tagged for internal QA if explicitly allowed in release issue.
