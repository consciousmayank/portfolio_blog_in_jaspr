#!/usr/bin/env bash
# admin/scripts/build-android.sh — produce a signed release APK pointing at prod.
#
# Output: build/app/outputs/flutter-apk/app-release.apk
#
# Override the API URL with API_BASE_URL=... before invoking, e.g.
#   API_BASE_URL=http://10.0.2.2:8080 ./scripts/build-android.sh
# (10.0.2.2 reaches the host machine from an Android emulator.)

set -euo pipefail
cd "$(dirname "$0")/.."

BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()  { printf '%s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }

API_BASE_URL="${API_BASE_URL:-https://mayankjoshi.in}"

if [ ! -f android/key.properties ]; then
  warn "android/key.properties not found — release will fall back to debug signing."
  warn "Run ./scripts/init-keystore.sh once for proper update-in-place signing."
fi

if ! command -v flutter >/dev/null 2>&1; then
  err "flutter not on PATH"; exit 1
fi

printf '%sBuilding release APK%s — API_BASE_URL=%s\n' "$BOLD" "$RESET" "$API_BASE_URL"

flutter pub get >/dev/null
flutter build apk --release \
  --dart-define=API_BASE_URL="$API_BASE_URL"

APK=build/app/outputs/flutter-apk/app-release.apk
if [ ! -f "$APK" ]; then
  err "APK not found at $APK after build"
  exit 1
fi

ok "Built $APK ($(du -h "$APK" | awk '{print $1}'))"
echo
echo "Install via USB:  adb install -r $APK"
echo "Sideload manually: AirDrop / Drive / email this file to your phone, then open it."
