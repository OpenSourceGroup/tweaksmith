# GitHub Labels

Create these labels in the repository (colors are suggestions).

| Label | Color | Purpose |
|-------|-------|---------|
| `inbox` | `#D4C5F9` | Project Inbox (untriaged; not approved) |
| `now` | `#B60205` | Approved for current sprint / v0.1 critical path |
| `next` | `#D93F0B` | Queued after NOW |
| `later` | `#FBCA04` | Backlog |
| `experimental` | `#0E8A16` | Research or prototype; not committed ship |
| `wont-build` | `#FFFFFF` | Conflicts with PRODUCT_PRINCIPLES |
| `in-progress` | `#FBCA04` | Actively being implemented |
| `qa` | `#5319E7` | QA column — verify before release |
| `bug` | `#D73A4A` | Defect |
| `enhancement` | `#A2EEEF` | Feature or improvement |
| `compatibility` | `#C5DEF5` | OS/hardware/module conflicts |
| `research` | `#D4C5F9` | Inbox / Grok candidate tracking |
| `release-blocker` | `#B60205` | Blocks RC or production gate |
| `released` | `#0E8A16` | Shipped |
| `good-first-issue` | `#7057FF` | Small scoped contributor tasks |
| `documentation` | `#0075CA` | Docs-only |

Board column mapping (labels + milestones): [`docs/PROJECT_BOARD.md`](../docs/PROJECT_BOARD.md).

## Usage

- **Roadmap:** exactly one of `now`, `next`, `later`, `experimental`, `wont-build` on feature issues (maintainer-set)
- **Release:** `release-blocker` until gate passes
- **Research:** `research` until promoted or `wont-build`

## CLI (maintainers)

```bash
# Example: gh label create now --color B60205 --description "Current priority"
```

Replace org/repo in issue template URLs when repository is created.
