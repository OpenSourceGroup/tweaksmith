# GitHub operations — Tweaksmith

## Repositories

| Repo | Visibility | URL |
|------|------------|-----|
| `KamyabInfotech/tweaksmith` | Public | https://github.com/KamyabInfotech/tweaksmith |
| `KamyabInfotech/tweaksmith-intelligence` | Private | https://github.com/KamyabInfotech/tweaksmith-intelligence |

Official product site is **https://kamyab.co.in/tweaksmith** — not GitHub Pages.

Canonical distribution for official builds: **GitHub Releases** on the public repo (version, notes, signed/notarized archive, SHA-256 checksum, compatibility, limitations).

## Labels (mandatory)

`research`, `needs-verification`, `validated`, `approved`, `ready`, `in-progress`, `enhancement`, `experimental`, `compatibility`, `bug`, `security`, `release-blocker`, `released`, `wontfix`

Plus backlog: `now`, `next`, `later`, `documentation`, `good-first-issue`.

**Never** auto-move research → approved. Human approval required.

## Issue templates

Bug Report, Feature Request, Compatibility Issue, Research Candidate, Release Blocker (under `.github/ISSUE_TEMPLATE/`).

## Project board

**Active fallback:** labels + milestones (no Projects v2). Column map: [`docs/PROJECT_BOARD.md`](PROJECT_BOARD.md).

Desired Projects v2 statuses (when a token has `project` / `read:project`):

Inbox · NOW · NEXT · LATER · EXPERIMENTAL · WONT BUILD · In Progress · QA · Released

```bash
gh project create --owner KamyabInfotech --title "Tweaksmith"
# Then add Status field options matching the columns above; link repo tweaksmith
```

Machine note: GitHub OAuth in macOS **osxkeychain** (git credential for `github.com`) covers `repo` + `workflow` but **not** `project` / `read:project` / `read:org`. Prefer `export GH_TOKEN="$(~/.cursor/secrets/gh-token-from-osxkeychain.sh)"` for `gh api` (do not embed tokens in workflows). HTTPS remotes use the same credential helper.

## Branch protection (`main`) — applied soft

Goals: PR-based changes; no force-push; no deletion; optional CI; admin override for solo maintainer.

```bash
gh api -X PUT repos/KamyabInfotech/tweaksmith/branches/main/protection \
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

After CI is green, optionally set `required_status_checks.contexts` to `["CI"]` (or the exact job name). Keep `enforce_admins: false` so solo work stays usable.

## Intelligence repo

Private only. Native app **must not** depend on it. No payment/signing/Grok secrets — placeholders only.

## Human actions remaining

1. Optional: create org Projects v2 **Tweaksmith** when a PAT/App token with `project` + `read:project` is available (board fallback already live — see `PROJECT_BOARD.md`)
2. Add Apple notarization secrets to repo/org Actions when ready  
3. Install full Xcode for `.app` archive on signing Mac  
4. Razorpay TEST secrets on staging worker (see Kamyab `docs/TWEAKSMITH_SUPPORT.md`)
