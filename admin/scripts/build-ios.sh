#!/usr/bin/env bash
# admin/scripts/build-ios.sh — produce a release IPA pointing at prod.
#
# Output: build/ios/ipa/admin.ipa  (or similar — Xcode picks the name)
#
# REQUIRES (one-time):
#   - Apple Developer enrollment (paid program for App Distribution to devices)
#   - Open admin/ios/Runner.xcworkspace in Xcode
#   - Signing & Capabilities → set Team to your Apple Developer team
#   - Bundle ID stays "in.mayankjoshi.admin" — change ONLY if Apple says it's
#     unavailable in your account (must then match in pbxproj too).

set -euo pipefail
cd "$(dirname "$0")/.."

BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()  { printf '%s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  err "iOS builds only work on macOS"; exit 1
fi
if ! command -v flutter >/dev/null 2>&1; then
  err "flutter not on PATH"; exit 1
fi
if ! xcrun --version >/dev/null 2>&1; then
  err "Xcode command line tools not installed — run: xcode-select --install"; exit 1
fi

API_BASE_URL="${API_BASE_URL:-https://mayankjoshi.in}"

printf '%sBuilding release IPA%s — API_BASE_URL=%s\n' "$BOLD" "$RESET" "$API_BASE_URL"

flutter pub get >/dev/null
flutter build ipa --release \
  --dart-define=API_BASE_URL="$API_BASE_URL"

IPA=$(find build/ios/ipa -name '*.ipa' -type f 2>/dev/null | head -1)
if [ -z "$IPA" ]; then
  err "No IPA produced. Common causes:"
  err "  - Signing not set up in Xcode (Runner.xcworkspace → target → Signing & Capabilities)"
  err "  - Apple Developer enrollment lapsed"
  err "  - Bundle ID conflict in App Store Connect"
  exit 1
fi

ok "Built $IPA ($(du -h "$IPA" | awk '{print $1}'))"
echo
echo "Distribute via Firebase: ./scripts/release.sh ios"
