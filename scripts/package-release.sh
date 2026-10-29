#!/usr/bin/env bash
# Package Tweaksmith for GitHub Releases via SwiftPM (no Xcode.app required).
# Prefer signed+notarized builds when APPLE_* env / Developer ID identity exist.
# Otherwise produce an UNSIGNED / AD-HOC .app zip marked NOT for Gatekeeper distribution.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-${TWEAKSMITH_VERSION:-0.1.0-rc.1}}"
DIST="${ROOT}/dist"
APP_NAME="Tweaksmith"
BUNDLE_ID="co.in.kamyab.tweaksmith"
MIN_SYS="26.0"
BUILD_HOST="$(sw_vers -productVersion 2>/dev/null || echo unknown)"
ARCH="$(uname -m)"

SIGNING_MODE="unsigned-adhoc"
NOTARIZED="no"
HAS_DEV_ID="no"

mkdir -p "$DIST"
rm -rf "${DIST:?}/${APP_NAME}.app" "${DIST:?}/${APP_NAME}"*.zip "${DIST:?}/SHA256SUMS.txt" \
  "${DIST:?}/RELEASE_NOTES.md" "${DIST:?}/COMPATIBILITY_NOTES.md" "${DIST:?}/KNOWN_LIMITATIONS.md" \
  "${DIST:?}/ARTIFACT_META.txt"

echo "==> Building release executable (SwiftPM)"
swift build -c release --product Tweaksmith

BIN="$(swift build -c release --product Tweaksmith --show-bin-path)/Tweaksmith"
if [[ ! -x "$BIN" ]]; then
  echo "error: release binary missing at $BIN" >&2
  exit 1
fi

APP="${DIST}/${APP_NAME}.app"
CONTENTS="${APP}/Contents"
MACOS="${CONTENTS}/MacOS"
RES="${CONTENTS}/Resources"
mkdir -p "$MACOS" "$RES"

cp "$BIN" "${MACOS}/${APP_NAME}"
chmod +x "${MACOS}/${APP_NAME}"

# Bundle resource catalog if SPM emitted one next to the binary.
if [[ -d "$(dirname "$BIN")/${APP_NAME}_${APP_NAME}.bundle" ]]; then
  cp -R "$(dirname "$BIN")/${APP_NAME}_${APP_NAME}.bundle" "${RES}/"
fi
if [[ -d "${ROOT}/Tweaksmith/Resources" ]]; then
  # Copy non-empty resource files only (skip .gitkeep-only trees as noise).
  find "${ROOT}/Tweaksmith/Resources" -type f ! -name '.gitkeep' -print0 2>/dev/null \
    | while IFS= read -r -d '' f; do
        rel="${f#${ROOT}/Tweaksmith/Resources/}"
        mkdir -p "${RES}/$(dirname "$rel")"
        cp "$f" "${RES}/${rel}"
      done
fi

cat > "${CONTENTS}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>${APP_NAME}</string>
	<key>CFBundleIdentifier</key>
	<string>${BUNDLE_ID}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>${APP_NAME}</string>
	<key>CFBundleDisplayName</key>
	<string>${APP_NAME}</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>${VERSION}</string>
	<key>CFBundleVersion</key>
	<string>${VERSION}</string>
	<key>LSMinimumSystemVersion</key>
	<string>${MIN_SYS}</string>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.utilities</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
EOF

# Ensure AppIcon.icns lands in Resources even if find-copy missed it.
if [[ -f "${ROOT}/Tweaksmith/Resources/AppIcon.icns" ]]; then
  cp "${ROOT}/Tweaksmith/Resources/AppIcon.icns" "${RES}/AppIcon.icns"
fi

# Optional Developer ID path (never log secret values).
if [[ -n "${APPLE_CERTIFICATE_BASE64:-}" && -n "${APPLE_CERTIFICATE_PASSWORD:-}" ]]; then
  echo "==> Importing Developer ID certificate from env (secrets not printed)"
  KEYCHAIN_PWD="$(openssl rand -base64 24)"
  KEYCHAIN_PATH="${DIST}/tweaksmith-signing.keychain-db"
  security create-keychain -p "$KEYCHAIN_PWD" "$KEYCHAIN_PATH"
  security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
  security unlock-keychain -p "$KEYCHAIN_PWD" "$KEYCHAIN_PATH"
  CERT_TMP="$(mktemp)"
  printf '%s' "$APPLE_CERTIFICATE_BASE64" | base64 -d > "$CERT_TMP"
  security import "$CERT_TMP" -k "$KEYCHAIN_PATH" -P "$APPLE_CERTIFICATE_PASSWORD" -T /usr/bin/codesign -T /usr/bin/security
  rm -f "$CERT_TMP"
  security list-keychains -d user -s "$KEYCHAIN_PATH" $(security list-keychains -d user | sed 's/"//g')
  security set-key-partition-list -S apple-tool:,apple: -s -k "$KEYCHAIN_PWD" "$KEYCHAIN_PATH" >/dev/null
  IDENTITY="$(security find-identity -v -p codesigning "$KEYCHAIN_PATH" | awk -F'"' '/Developer ID Application/{print $2; exit}')"
  if [[ -n "$IDENTITY" ]]; then
    HAS_DEV_ID="yes"
    codesign --force --options runtime --timestamp --sign "$IDENTITY" "${MACOS}/${APP_NAME}"
    codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
    SIGNING_MODE="developer-id"
  else
    echo "warning: certificate imported but no Developer ID Application identity found" >&2
  fi
elif security find-identity -v -p codesigning 2>/dev/null | grep -q 'Developer ID Application'; then
  IDENTITY="$(security find-identity -v -p codesigning | awk -F'"' '/Developer ID Application/{print $2; exit}')"
  HAS_DEV_ID="yes"
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "${MACOS}/${APP_NAME}"
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
  SIGNING_MODE="developer-id"
else
  echo "==> No Developer ID — ad-hoc codesign (NOT for public Gatekeeper distribution)"
  find "$APP" -name '._*' -delete 2>/dev/null || true
  xattr -cr "$APP" 2>/dev/null || true
  find "$APP" -print0 2>/dev/null | xargs -0 xattr -c 2>/dev/null || true
  codesign --force --sign - --timestamp=none "${MACOS}/${APP_NAME}" 2>/dev/null || true
  codesign --force --deep --sign - --timestamp=none "$APP"
  SIGNING_MODE="unsigned-adhoc"
fi

if [[ "$SIGNING_MODE" == "developer-id" && -n "${APPLE_ID:-}" && -n "${APPLE_APP_SPECIFIC_PASSWORD:-}" && -n "${APPLE_TEAM_ID:-}" ]]; then
  echo "==> Submitting for notarization (credentials not printed)"
  ZIP_NOTARY="${DIST}/${APP_NAME}-${VERSION}-notarize.zip"
  ditto -c -k --keepParent "$APP" "$ZIP_NOTARY"
  if ! xcrun notarytool submit "$ZIP_NOTARY" \
      --apple-id "$APPLE_ID" \
      --password "$APPLE_APP_SPECIFIC_PASSWORD" \
      --team-id "$APPLE_TEAM_ID" \
      --wait; then
    rm -f "$ZIP_NOTARY"
    echo "error: notarization failed — refusing to continue as Gatekeeper-ready" >&2
    exit 1
  fi
  if ! xcrun stapler staple "$APP"; then
    rm -f "$ZIP_NOTARY"
    echo "error: stapler failed after notarization" >&2
    exit 1
  fi
  NOTARIZED="yes"
  rm -f "$ZIP_NOTARY"
  echo "==> Verifying Gatekeeper assessment (no bypass)"
  spctl --assess --type execute --verbose=4 "$APP"
  codesign --verify --deep --strict --verbose=2 "$APP"
fi

ZIP_NAME="${APP_NAME}-${VERSION}-macos-arm64"
if [[ "$SIGNING_MODE" != "developer-id" || "$NOTARIZED" != "yes" ]]; then
  ZIP_NAME="${ZIP_NAME}-UNSIGNED-NOT-FOR-GATEKEEPER"
fi
ZIP_PATH="${DIST}/${ZIP_NAME}.zip"
# Strip AppleDouble / FinderInfo before final seal + zip (keeps codesign valid after extract).
find "$APP" -name '._*' -delete 2>/dev/null || true
xattr -cr "$APP" 2>/dev/null || true
find "$APP" -print0 2>/dev/null | xargs -0 xattr -c 2>/dev/null || true
# Re-seal after xattr strip (ad-hoc or Dev ID).
if [[ "$SIGNING_MODE" == "unsigned-adhoc" ]]; then
  codesign --force --deep --sign - --timestamp=none "$APP"
elif [[ "$SIGNING_MODE" == "developer-id" ]]; then
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
fi
COPYFILE_DISABLE=1 ditto -c -k --norsrc --keepParent "$APP" "$ZIP_PATH"

# Also ship bare binary archive for CLT / headless validation.
BIN_ZIP="${DIST}/${APP_NAME}-${VERSION}-macos-arm64-binary-ONLY.zip"
(
  cd "$(dirname "$BIN")"
  ditto -c -k "$(basename "$BIN")" "$BIN_ZIP"
)

cat > "${DIST}/COMPATIBILITY_NOTES.md" <<EOF
# Compatibility — Tweaksmith ${VERSION}

- **OS:** macOS Tahoe **26+** (LSMinimumSystemVersion ${MIN_SYS})
- **CPU:** Apple Silicon (arm64) primary; this artifact is **arm64-only**
- **Build host:** macOS ${BUILD_HOST} / ${ARCH}
- **Forbidden:** SIP disabled, Gatekeeper disabled globally, modified system frameworks, kexts

See \`docs/COMPATIBILITY.md\` in the repository for Window Corners / preference risk notes.
EOF

cat > "${DIST}/KNOWN_LIMITATIONS.md" <<EOF
# Known limitations — Tweaksmith ${VERSION}

1. **Signing:** mode=\`${SIGNING_MODE}\`; notarized=\`${NOTARIZED}\`. If not Developer ID + notarized, **do not** publish as the official Gatekeeper download.
2. Packaging uses SwiftPM \`.app\` wrap (not \`xcodebuild\` archive); CI/local hosts without Xcode.app skip XCTest and use smoke.
3. **NSConvolutionOverride2** may be absent; UI must not expose unsupported overrides.
4. **Window Corners** may require logout/restart; preview is illustrative.
5. **Support payments** may be Razorpay TEST-only until production cut-over.
EOF

# Release notes from CHANGELOG section when present.
{
  echo "# Tweaksmith ${VERSION}"
  echo
  if [[ "$SIGNING_MODE" != "developer-id" || "$NOTARIZED" != "yes" ]]; then
    echo "> **DRAFT / RC artifact — UNSIGNED or AD-HOC.** Not for public Gatekeeper distribution."
    echo
  fi
  echo "## Compatibility"
  echo
  cat "${DIST}/COMPATIBILITY_NOTES.md" | sed '1d'
  echo
  echo "## Known limitations"
  echo
  cat "${DIST}/KNOWN_LIMITATIONS.md" | sed '1d'
  echo
  if grep -q "## \[${VERSION}\]" CHANGELOG.md 2>/dev/null; then
    echo "## Changelog"
    echo
    # Extract section until next ## [
    awk -v ver="## [${VERSION}]" '
      $0 ~ ver {p=1; next}
      p && /^## \[/ {exit}
      p {print}
    ' CHANGELOG.md
  else
    echo "## Changelog"
    echo
    echo "See CHANGELOG.md for ${VERSION}."
  fi
} > "${DIST}/RELEASE_NOTES.md"

cat > "${DIST}/ARTIFACT_META.txt" <<EOF
version=${VERSION}
signing_mode=${SIGNING_MODE}
notarized=${NOTARIZED}
developer_id_identity_present=${HAS_DEV_ID}
bundle_id=${BUNDLE_ID}
min_system=${MIN_SYS}
arch=arm64
build_host_macos=${BUILD_HOST}
artifact_zip=$(basename "$ZIP_PATH")
binary_zip=$(basename "$BIN_ZIP")
gatekeeper_public_ok=$([ "$SIGNING_MODE" = "developer-id" ] && [ "$NOTARIZED" = "yes" ] && echo yes || echo no)
EOF

(
  cd "$DIST"
  shasum -a 256 \
    "$(basename "$ZIP_PATH")" \
    "$(basename "$BIN_ZIP")" \
    RELEASE_NOTES.md \
    COMPATIBILITY_NOTES.md \
    KNOWN_LIMITATIONS.md \
    ARTIFACT_META.txt \
    > SHA256SUMS.txt
)

echo
echo "==> Packaged ${VERSION}"
echo "    app:  $APP"
echo "    zip:  $ZIP_PATH"
echo "    mode: $SIGNING_MODE  notarized=$NOTARIZED"
echo "    sums: ${DIST}/SHA256SUMS.txt"
cat "${DIST}/SHA256SUMS.txt"
