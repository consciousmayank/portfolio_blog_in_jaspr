#!/usr/bin/env bash
# admin/scripts/release.sh — build + upload to Firebase App Distribution.
#
# Usage:
#   ./scripts/release.sh android         # APK → Firebase
#   ./scripts/release.sh ios             # IPA → Firebase
#   ./scripts/release.sh both            # both
#
# Required env (load from admin/.env — see admin/.env.example):
#   FIREBASE_ANDROID_APP_ID   e.g. 1:123456789:android:abcdef
#   FIREBASE_IOS_APP_ID       e.g. 1:123456789:ios:abcdef
#   FIREBASE_TESTERS          comma-separated emails OR FIREBASE_TESTER_GROUPS
#   FIREBASE_TESTER_GROUPS    comma-separated group aliases (e.g. "admins")
#
# First-time setup: see admin/FIREBASE_SETUP.md

set -euo pipefail
cd "$(dirname "$0")/.."

BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()  { printf '%s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }
step() { printf '\n%s== %s ==%s\n' "$BOLD" "$*" "$RESET"; }

TARGET="${1:-}"
if [[ -z "$TARGET" || ( "$TARGET" != "android" && "$TARGET" != "ios" && "$TARGET" != "both" ) ]]; then
  err "Usage: $0 {android|ios|both}"; exit 1
fi

if [ -f .env ]; then
  # shellcheck disable=SC1091
  set -a; source .env; set +a
  ok "Loaded admin/.env"
else
  warn "admin/.env not found — using ambient env vars only"
fi

if ! command -v firebase >/dev/null 2>&1; then
  err "firebase CLI not installed."
  err "Install:  npm install -g firebase-tools"
  err "Login:    firebase login"
  exit 1
fi

if ! firebase --json projects:list >/dev/null 2>&1; then
  err "firebase CLI isn't authenticated — run: firebase login"
  exit 1
fi

# Default release notes: short, includes git commit
RELEASE_NOTES="${RELEASE_NOTES:-}"
if [ -z "$RELEASE_NOTES" ]; then
  RELEASE_NOTES="$(cd .. && git log -1 --pretty=format:'%h %s' 2>/dev/null || echo 'admin build')"
fi

if [ -z "${FIREBASE_TESTER_GROUPS:-}" ] && [ -z "${FIREBASE_TESTERS:-}" ]; then
  err "Set FIREBASE_TESTER_GROUPS or FIREBASE_TESTERS in admin/.env"
  exit 1
fi

release_android() {
  step "Android"
  if [ -z "${FIREBASE_ANDROID_APP_ID:-}" ]; then
    err "FIREBASE_ANDROID_APP_ID is not set"; return 1
  fi
  ./scripts/build-android.sh
  local apk="build/app/outputs/flutter-apk/app-release.apk"
  step "Uploading APK to Firebase App Distribution"
  firebase appdistribution:distribute "$apk" \
    --app "$FIREBASE_ANDROID_APP_ID" \
    --release-notes "$RELEASE_NOTES" \
    ${FIREBASE_TESTER_GROUPS:+--groups "$FIREBASE_TESTER_GROUPS"} \
    ${FIREBASE_TESTERS:+--testers "$FIREBASE_TESTERS"}
  ok "Android build distributed"
}

release_ios() {
  step "iOS"
  if [ -z "${FIREBASE_IOS_APP_ID:-}" ]; then
    err "FIREBASE_IOS_APP_ID is not set"; return 1
  fi
  ./scripts/build-ios.sh
  local ipa
  ipa=$(find build/ios/ipa -name '*.ipa' -type f | head -1)
  step "Uploading IPA to Firebase App Distribution"
  firebase appdistribution:distribute "$ipa" \
    --app "$FIREBASE_IOS_APP_ID" \
    --release-notes "$RELEASE_NOTES" \
    ${FIREBASE_TESTER_GROUPS:+--groups "$FIREBASE_TESTER_GROUPS"} \
    ${FIREBASE_TESTERS:+--testers "$FIREBASE_TESTERS"}
  ok "iOS build distributed"
}

case "$TARGET" in
  android) release_android ;;
  ios)     release_ios ;;
  both)    release_android; release_ios ;;
esac

step "Done"
echo "Testers will get an email from Firebase with an install link."
echo "They'll need the 'Firebase App Tester' app installed once (https://appdistribution.firebase.dev/)"
