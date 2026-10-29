#!/usr/bin/env bash
# Runs automated checks then points at docs/RELEASE_GATE.md for human sign-off.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== Tweaksmith release-gate =="
chmod +x scripts/bootstrap-check.sh scripts/run-smoke.sh scripts/run-swift-test.sh
./scripts/bootstrap-check.sh
./scripts/run-smoke.sh
if xcodebuild -version >/dev/null 2>&1; then
  ./scripts/run-swift-test.sh
  echo ""
  echo "Automated suite: PASS (smoke + XCTest + bootstrap)"
else
  echo ""
  echo "Automated suite: PASS (smoke + bootstrap; XCTest skipped — no Xcode)"
fi
echo "Full human checklist: docs/RELEASE_GATE.md"
echo "Recorded bootstrap verdict: docs/RELEASE_GATE_VERDICT.md"
if [[ -f docs/RELEASE_GATE_VERDICT.md ]]; then
  rg -n "^\*\*READY|READY WITH|BLOCKED" docs/RELEASE_GATE_VERDICT.md || true
fi
echo ""
echo "Exact verdict must be one of: READY | READY WITH KNOWN LIMITATIONS | BLOCKED"
echo "== release-gate complete =="
