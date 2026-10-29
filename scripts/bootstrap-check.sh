#!/usr/bin/env bash
# Tweaksmith bootstrap sanity check.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Tweaksmith bootstrap-check =="
echo "1. Verify docs: PRODUCT_PRINCIPLES, ARCHITECTURE, RELEASE_GATE, DEVELOPMENT present"
for f in docs/PRODUCT_PRINCIPLES.md docs/ARCHITECTURE.md docs/RELEASE_GATE.md docs/DEVELOPMENT.md; do
  [[ -f "$f" ]] && echo "   OK $f" || echo "   MISSING $f"
done

echo "2. Verify GitHub templates and workflows"
[[ -f .github/PULL_REQUEST_TEMPLATE.md ]] && echo "   OK PR template" || echo "   MISSING PR template"
[[ -f .github/workflows/ci.yml ]] && echo "   OK ci.yml" || echo "   MISSING ci.yml"
[[ ! -f .github/workflows/research-intake.yml ]] && echo "   OK no research-intake workflow" || echo "   UNEXPECTED research-intake.yml still present"
[[ ! -d research ]] && echo "   OK no research/ tree" || echo "   UNEXPECTED research/ still present"

echo "3. Swift/Xcode (when present): run isolated-domain tests only — never mutate runner global prefs"
if command -v swift >/dev/null 2>&1 && [[ -f Package.swift ]]; then
  echo "   Found Package.swift — run: swift test (with isolated preference domains in tests)"
elif compgen -G "*.xcodeproj" >/dev/null 2>&1 || compgen -G "*.xcworkspace" >/dev/null 2>&1; then
  echo "   Found Xcode project — run xcodebuild test with isolated domains"
else
  echo "   No Swift package/project yet — skip build until app sources land"
fi

echo "4. Secrets: never commit; CI uses GitHub Environments for notarization when configured"
echo "== bootstrap-check complete =="
