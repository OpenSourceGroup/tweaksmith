#!/usr/bin/env bash
# Fail-closed checks on dist/ARTIFACT_META.txt and packaged .app (when present).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="${ROOT}/dist"
META="${DIST}/ARTIFACT_META.txt"
REQUIRE_GATEKEEPER="${TWEAKSMITH_REQUIRE_GATEKEEPER:-no}"

if [[ ! -f "$META" ]]; then
  echo "error: missing ${META} — run scripts/package-release.sh first" >&2
  exit 1
fi

meta_get() {
  local key="$1"
  awk -F= -v k="$key" '$1 == k { print substr($0, index($0, "=") + 1); exit }' "$META"
}

ARTIFACT_version="$(meta_get version)"
ARTIFACT_signing_mode="$(meta_get signing_mode)"
ARTIFACT_notarized="$(meta_get notarized)"
ARTIFACT_gatekeeper_public_ok="$(meta_get gatekeeper_public_ok)"

echo "== validate-release-artifact =="
echo "    version=${ARTIFACT_version:-unknown}"
echo "    signing_mode=${ARTIFACT_signing_mode:-unknown}"
echo "    notarized=${ARTIFACT_notarized:-unknown}"
echo "    gatekeeper_public_ok=${ARTIFACT_gatekeeper_public_ok:-unknown}"

if [[ "$ARTIFACT_signing_mode" == "developer-id" && "$ARTIFACT_notarized" != "yes" ]]; then
  echo "warning: Developer ID signing without notarization — NOT Gatekeeper-public" >&2
  if [[ "$REQUIRE_GATEKEEPER" == "yes" ]]; then
    echo "error: TWEAKSMITH_REQUIRE_GATEKEEPER=yes requires notarized artifact" >&2
    exit 1
  fi
fi

if [[ "$REQUIRE_GATEKEEPER" == "yes" ]]; then
  if [[ "${ARTIFACT_gatekeeper_public_ok:-no}" != "yes" ]]; then
    echo "error: TWEAKSMITH_REQUIRE_GATEKEEPER=yes but artifact is not Gatekeeper-ready" >&2
    exit 1
  fi
  APP_GLOB=("${DIST}"/Tweaksmith.app)
  if [[ -d "${APP_GLOB[0]}" ]]; then
    echo "==> spctl assess (required)"
    spctl --assess --type execute --verbose=4 "${APP_GLOB[0]}"
    echo "==> codesign verify (required)"
    codesign --verify --deep --strict --verbose=2 "${APP_GLOB[0]}"
    echo "==> stapler validate"
    xcrun stapler validate "${APP_GLOB[0]}"
  else
    echo "warning: Tweaksmith.app not found under dist — skipping live spctl/stapler"
  fi
fi

if [[ "${ARTIFACT_gatekeeper_public_ok:-no}" != "yes" ]]; then
  echo "NOTE: Artifact is NOT Stable / Gatekeeper-public (unsigned or not notarized)."
  if [[ "$REQUIRE_GATEKEEPER" == "yes" ]]; then
    exit 1
  fi
fi

echo "== validate-release-artifact: OK =="
