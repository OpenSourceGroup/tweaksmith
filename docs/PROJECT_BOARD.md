# Tweaksmith project board (label + milestone fallback)

A GitHub **Projects v2** board titled “Tweaksmith” is **not** available from machine credentials today (OAuth scopes: `repo`, `workflow`, `read:user`, `user:email` — missing `project` / `read:project`).

Until an org token with project scopes exists, the backlog uses **issue labels + milestones** on [`KamyabInfotech/tweaksmith`](https://github.com/KamyabInfotech/tweaksmith).

**Never** auto-move research → approved. Humans set roadmap labels.

## Column map

| Board column | Primary label | Milestone | Notes |
|--------------|---------------|-----------|--------|
| Inbox | `inbox` or `research` | Inbox | Untriaged / Grok candidates |
| NOW | `now` | NOW | Approved current priority |
| NEXT | `next` | NEXT | Queued after NOW |
| LATER | `later` | LATER | Backlog |
| EXPERIMENTAL | `experimental` | EXPERIMENTAL | Prototype; not committed ship |
| WONT BUILD | `wont-build` | WONT BUILD | Conflicts with PRODUCT_PRINCIPLES |
| In Progress | `in-progress` | In Progress | Active engineering |
| QA | `qa` | QA | Verify before release |
| Released | `released` | Released | Shipped |

Exactly **one** roadmap label among `now` / `next` / `later` / `experimental` / `wont-build` on feature issues (maintainers).

## Views

- Labels: https://github.com/KamyabInfotech/tweaksmith/labels  
- Milestones: https://github.com/KamyabInfotech/tweaksmith/milestones  
- Open NOW: https://github.com/KamyabInfotech/tweaksmith/issues?q=is%3Aissue+is%3Aopen+label%3Anow

## Projects v2 (when scopes exist)

```bash
gh project create --owner KamyabInfotech --title "Tweaksmith"
# Add Status options: Inbox, NOW, NEXT, LATER, EXPERIMENTAL, WONT BUILD, In Progress, QA, Released
# Link repo KamyabInfotech/tweaksmith
```

See also: [GITHUB_OPS.md](GITHUB_OPS.md), [.github/LABELS.md](../.github/LABELS.md), [ROADMAP.md](ROADMAP.md).
