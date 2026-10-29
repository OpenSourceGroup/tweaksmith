# Tweaksmith project board (label + milestone fallback)

A GitHub **Projects v2** board titled “Tweaksmith” is optional. Until an org token with project scopes exists, the backlog uses **issue labels + milestones** on [`OpenSourceGroup/tweaksmith`](https://github.com/OpenSourceGroup/tweaksmith).

Maintainers set roadmap labels. Contributors propose via Feature / Bug / Compatibility templates.

## Column map

| Board column | Primary label | Milestone | Notes |
|--------------|---------------|-----------|--------|
| Inbox | `inbox` | Inbox | Untriaged |
| Now | `now` | NOW | Current priority |
| Next | `next` | NEXT | Queued after Now |
| Later | `later` | LATER | Backlog |
| Experimental | `experimental` | EXPERIMENTAL | Prototype; not committed ship |
| Wont build | `wont-build` | WONT BUILD | Conflicts with PRODUCT_PRINCIPLES |
| In Progress | `in-progress` | In Progress | Active engineering |
| QA | `qa` | QA | Verify before release |
| Released | `released` | Released | Shipped |

Exactly **one** roadmap label among `now` / `next` / `later` / `experimental` / `wont-build` on feature issues (maintainers).

## Views

- Labels: https://github.com/OpenSourceGroup/tweaksmith/labels  
- Milestones: https://github.com/OpenSourceGroup/tweaksmith/milestones  
- Open Now: https://github.com/OpenSourceGroup/tweaksmith/issues?q=is%3Aissue+is%3Aopen+label%3Anow

## Projects v2 (when scopes exist)

```bash
gh project create --owner OpenSourceGroup --title "Tweaksmith"
# Add Status options: Inbox, Now, Next, Later, Experimental, Wont build, In Progress, QA, Released
# Link repo OpenSourceGroup/tweaksmith
```

See also: [GITHUB_OPS.md](GITHUB_OPS.md), [.github/LABELS.md](../.github/LABELS.md), [ROADMAP.md](ROADMAP.md).
