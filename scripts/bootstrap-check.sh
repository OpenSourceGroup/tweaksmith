#!/usr/bin/env bash
# Tweaksmith bootstrap sanity check (stub — expand as app lands in repo).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Tweaksmith bootstrap-check =="
echo "1. Verify docs: PRODUCT_PRINCIPLES, ARCHITECTURE, RELEASE_GATE present"
for f in docs/PRODUCT_PRINCIPLES.md docs/ARCHITECTURE.md docs/RELEASE_GATE.md; do
  [[ -f "$f" ]] && echo "   OK $f" || echo "   MISSING $f"
done

echo "2. Verify research paths: inbox, reports, approved"
for d in research/inbox research/reports research/approved; do
  [[ -d "$d" ]] && echo "   OK $d" || echo "   MISSING $d"
done

echo "3. Verify GitHub templates and workflows"
[[ -f .github/PULL_REQUEST_TEMPLATE.md ]] && echo "   OK PR template" || echo "   MISSING PR template"
[[ -f .github/workflows/ci.yml ]] && echo "   OK ci.yml" || echo "   MISSING ci.yml"

echo "4. Swift/Xcode (when present): run isolated-domain tests only — never mutate runner global prefs"
if command -v swift >/dev/null 2>&1 && [[ -f Package.swift ]]; then
  echo "   Found Package.swift — run: swift test (with isolated preference domains in tests)"
elif [[ -d *.xcodeproj ]] || [[ -d *.xcworkspace ]]; then
  echo "   Found Xcode project — run xcodebuild test with isolated domains"
else
  echo "   No Swift package/project yet — skip build until app sources land"
fi

echo "5. Secrets: never commit; CI uses GitHub Environments for notarization when configured"
echo "== bootstrap-check complete (stub) =="
