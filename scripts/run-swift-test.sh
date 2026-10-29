#!/usr/bin/env bash
# Run XCTest with isolated preference domains.
# On macOS Tahoe+, build products can gain Finder/fileprovider xattrs that make
# ad-hoc codesign fail ("resource fork, Finder information, or similar detritus").
# Recover by clearing xattrs and re-signing products, then re-running without rebuild.
set -euo pipefail
cd "$(dirname "$0")/.."
export TWEAKSMITH_TEST_ISOLATED_PREFS=1

strip_and_adhoc_sign_products() {
  local root=".build"
  [[ -d "$root" ]] || return 0
  # Prefer Products tree when present (Xcode-integrated SwiftPM layout).
  local search=("$root")
  [[ -d "$root/out/Products" ]] && search=("$root/out/Products")
  find "${search[@]}" \( -name '*.xctest' -o -name '*.app' -o -name '*.bundle' \) -print0 2>/dev/null \
    | while IFS= read -r -d '' p; do
        xattr -cr "$p" 2>/dev/null || true
        /usr/bin/codesign --force --sign - --timestamp=none --generate-entitlement-der "$p" >/dev/null 2>&1 || true
      done
}

if swift test "$@"; then
  exit 0
fi

echo "swift test failed — attempting Tahoe xattr/codesign recovery" >&2
strip_and_adhoc_sign_products
swift test --skip-build "$@"
