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

## Project board (manual — token needs `project` scope)

Create **Tweaksmith** project with statuses/columns:

Inbox · NOW · NEXT · LATER · EXPERIMENTAL · WONT BUILD · In Progress · QA · Released

```bash
# After: gh auth refresh -s project,read:project
gh project create --owner KamyabInfotech --title "Tweaksmith"
# Then add Status field options matching the columns above
```

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

1. `gh auth refresh -s project,read:project` → create Project board  
2. Add Apple notarization secrets to repo/org Actions when ready  
3. Install full Xcode for `.app` archive on signing Mac  
4. Confirm branch protection UI after first push  
5. Razorpay TEST secrets on staging worker (see Kamyab `docs/TWEAKSMITH_SUPPORT.md`)
