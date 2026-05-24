#!/usr/bin/env bash
# admin/scripts/init-keystore.sh — one-time setup for Android release signing.
#
# Generates a JKS keystore + key.properties under android/, both gitignored.
# Keep the .jks file safe — losing it means future builds can't update the
# installed app in place (users would have to uninstall + reinstall).

set -euo pipefail
cd "$(dirname "$0")/.."

BOLD=$'\033[1m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$*"; }
err()  { printf '%s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }

KEYSTORE_DIR="android/keystore"
KEYSTORE_FILE="$KEYSTORE_DIR/release.jks"
PROPS_FILE="android/key.properties"
ALIAS="mjadmin"
VALIDITY_DAYS=10950 # 30 years; covers any realistic use

if [ -f "$KEYSTORE_FILE" ] || [ -f "$PROPS_FILE" ]; then
  err "A keystore already exists at $KEYSTORE_FILE or $PROPS_FILE"
  err "Refusing to overwrite. Delete them first if you really want a fresh keystore"
  err "(WARNING: a new keystore breaks update-in-place for already-installed APKs)."
  exit 1
fi

if ! command -v keytool >/dev/null 2>&1; then
  err "keytool not found — install a JDK (e.g. 'brew install --cask temurin')"
  exit 1
fi

mkdir -p "$KEYSTORE_DIR"

printf '%sGenerating a fresh release keystore.%s\n' "$BOLD" "$RESET"
printf 'You will be prompted for:\n'
printf '  - a %skeystore password%s (used to open the .jks file)\n' "$BOLD" "$RESET"
printf '  - then your name + org + locality (any reasonable values are fine)\n'
printf '  - finally, confirmation\n\n'

# Generate the keystore. keytool's interactive prompts handle the password
# and DN. We reuse the keystore password as the key password (-keypass = same).
read -r -s -p "Choose a strong keystore password: " STORE_PW; echo
read -r -s -p "Confirm the password: " STORE_PW2; echo
if [ "$STORE_PW" != "$STORE_PW2" ]; then
  err "passwords don't match"; exit 1
fi
if [ ${#STORE_PW} -lt 8 ]; then
  err "password must be at least 8 characters"; exit 1
fi

keytool -genkeypair -v \
  -keystore "$KEYSTORE_FILE" \
  -keyalg RSA -keysize 4096 -validity "$VALIDITY_DAYS" \
  -alias "$ALIAS" \
  -storepass "$STORE_PW" \
  -keypass "$STORE_PW" \
  -dname "CN=Mayank Joshi, OU=Admin, O=mayankjoshi.in, L=Uttarakhand, S=Uttarakhand, C=IN"

ok "Keystore written to $KEYSTORE_FILE"

umask 077
cat > "$PROPS_FILE" <<EOF
storeFile=keystore/release.jks
storePassword=$STORE_PW
keyAlias=$ALIAS
keyPassword=$STORE_PW
EOF
chmod 600 "$PROPS_FILE"
ok "Signing config written to $PROPS_FILE (mode 600)"

cat <<EOF

${BOLD}Important — back this up now:${RESET}
  $(pwd)/$KEYSTORE_FILE
  $(pwd)/$PROPS_FILE

  If you lose either of these, every device with the app installed will need
  to uninstall + reinstall before they can take an update. Copy them to a
  password manager / iCloud Keychain / 1Password.

Next: ./scripts/build-android.sh
EOF
