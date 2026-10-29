#!/usr/bin/env bash
# Fail-safe release orchestrator — never auto-publishes a public Gatekeeper release.
# Usage: ./scripts/release.sh [version]
# Env (optional, never print values): APPLE_ID, APPLE_APP_SPECIFIC_PASSWORD, APPLE_TEAM_ID,
#   APPLE_CERTIFICATE_BASE64, APPLE_CERTIFICATE_PASSWORD
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-${TWEAKSMITH_VERSION:-0.1.0-rc.1}}"
AUTO_PUBLISH="${TWEAKSMITH_AUTO_PUBLISH:-no}"

if [[ "$AUTO_PUBLISH" == "yes" ]]; then
  echo "error: TWEAKSMITH_AUTO_PUBLISH=yes is refused. Publish only via human-approved GitHub Release." >&2
  exit 2
fi

# Do not hardcode signing identities — package-release discovers from keychain/env.
unset CODESIGN_IDENTITY IDENTITY 2>/dev/null || true

echo "==> release.sh ${VERSION} (fail-safe; no auto-publish)"
./scripts/bootstrap-check.sh
./scripts/run-smoke.sh
./scripts/package-release.sh "$VERSION"

META="${ROOT}/dist/ARTIFACT_META.txt"
if [[ ! -f "$META" ]]; then
  echo "error: missing ARTIFACT_META.txt" >&2
  exit 1
fi

GATEKEEPER_OK="$(awk -F= '/^gatekeeper_public_ok=/{print $2}' "$META")"
SIGNING="$(awk -F= '/^signing_mode=/{print $2}' "$META")"
NOTARIZED="$(awk -F= '/^notarized=/{print $2}' "$META")"

echo
echo "==> Artifact summary"
echo "    signing_mode=$SIGNING notarized=$NOTARIZED gatekeeper_public_ok=$GATEKEEPER_OK"
echo "    See dist/SHA256SUMS.txt and docs/RELEASE_GATE.md"
echo
if [[ "$GATEKEEPER_OK" != "yes" ]]; then
  echo "==> NOT Gatekeeper-ready. Create a **draft** GitHub Release only; do not mark latest/public."
  echo "    Example:"
  echo "    gh release create v${VERSION} --draft --title \"Tweaksmith ${VERSION} (UNSIGNED DRAFT)\" \\"
  echo "      dist/*.zip dist/SHA256SUMS.txt dist/RELEASE_NOTES.md dist/COMPATIBILITY_NOTES.md dist/KNOWN_LIMITATIONS.md dist/ARTIFACT_META.txt"
else
  echo "==> Signed+notarized artifact present. Still requires human RELEASE_GATE approval before publishing."
fi

echo "==> release.sh complete (no publish performed)"
