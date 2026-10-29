## Summary

<!-- What changed and why -->

## Linked issues

<!-- Fixes #123 -->

## Checklist

- [ ] Read `docs/PRODUCT_PRINCIPLES.md`; change aligns with non-negotiables
- [ ] Settings Engine path used for preference writes (no bypass)
- [ ] Tests use **isolated preference domains** — no runner global `defaults` mutation
- [ ] Support URLs open in browser only; no trust of `?paid=true`
- [ ] No secrets, tokens, or personal data in diff or logs
- [ ] `docs/COMPATIBILITY.md` updated if keys or restart behavior changed
- [ ] CHANGELOG.md updated (Unreleased) for user-visible changes

## Release gate (if RC/production)

- [ ] Not applicable
- [ ] RELEASE_GATE.md section(s) re-checked: ___________
- [ ] Verdict: READY | READY WITH KNOWN LIMITATIONS | BLOCKED

## Screenshots / testing

<!-- macOS version, chip, steps -->
