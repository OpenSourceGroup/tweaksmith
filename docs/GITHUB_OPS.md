# GitHub operations — Tweaksmith

## Repository

| Repo | Visibility | URL |
|------|------------|-----|
| `OpenSourceGroup/tweaksmith` | Public | https://github.com/OpenSourceGroup/tweaksmith |

Canonical URLs also live in [`GOVERNANCE.md`](../GOVERNANCE.md). Kamyab Infotech is the lead maintainer. `KamyabInfotech/tweaksmith` redirects to this repository.

Official product site is **https://kamyab.co.in/tweaksmith** — not GitHub Pages.

Canonical distribution for official builds: **GitHub Releases** on this repo (version, notes, signed/notarized archive, SHA-256 checksum, compatibility, limitations).

## Labels

See [`.github/LABELS.md`](../.github/LABELS.md). Conventional OSS labels plus roadmap: `now`, `next`, `later`, `experimental`, `wont-build`, `inbox`.

## Issue templates

Bug report, Feature request, Compatibility report, Release blocker (under `.github/ISSUE_TEMPLATE/`). No serial / Apple ID fields; redact PII.

## Discussions

Enabled on the public repo. Prefer a small set of categories: **General**, **Ideas**, **Help**, **Testing Feedback** (plus GitHub’s Announcements if present). Avoid category sprawl. Category create/rename is Settings UI (API unavailable to this token) — keep Q&A as Help until renamed.

## Commit hygiene (forward-looking)

Do not add AI/tool `Co-authored-by` trailers on new public commits. Do not rewrite history for past trailers.

## Project board

**Active fallback:** labels + milestones. Column map: [`docs/PROJECT_BOARD.md`](PROJECT_BOARD.md).

Desired Projects v2 statuses (when a token has `project` / `read:project`):

Inbox · Now · Next · Later · Experimental · Wont build · In Progress · QA · Released

```bash
gh project create --owner OpenSourceGroup --title "Tweaksmith"
# Then add Status field options matching the columns above; link repo tweaksmith
```

For scripted `gh api` calls, use a local credential helper or a scoped PAT — do not embed tokens in workflows or the repo.

## Branch protection (`main`) — soft

Goals: no force-push; no deletion; optional required CI; admin override for solo maintainer.

```bash
gh api -X PUT repos/OpenSourceGroup/tweaksmith/branches/main/protection \
  --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

After CI is green, optionally set `required_status_checks.contexts` to `["test"]` (exact job name). Keep `enforce_admins: false` so solo work stays usable.

## Human actions remaining

1. Optional: create org Projects v2 **Tweaksmith** when a PAT/App token with `project` + `read:project` is available
2. Add Apple notarization secrets to repo/org Actions when ready (`APPLE_ID`, `APPLE_APP_SPECIFIC_PASSWORD`, `APPLE_TEAM_ID`, `APPLE_CERTIFICATE_BASE64`, `APPLE_CERTIFICATE_PASSWORD`)
3. Install full Xcode (or use Actions macos + secrets) so `package-release.sh` can Developer ID–sign + notarize
4. Razorpay TEST secrets on staging worker before enabling preview checkout
5. Promote draft RC release only after notarized artifact exists — unsigned zips are **not** Gatekeeper-public
