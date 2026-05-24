# MJ Admin — Firebase App Distribution setup

One-time setup. After this, `./scripts/release.sh android` (or `ios`/`both`)
builds the app and ships it to your phone via Firebase.

---

## 1. Create a Firebase project (~3 min)

1. Go to <https://console.firebase.google.com/> and sign in with `consciousmayank@gmail.com`.
2. **Add project** → name it `mj-admin` (or anything). Skip Google Analytics.
3. Once created, you're in the project console.

## 2. Register the Android app (~2 min)

1. Project home → click the **Android** icon (or **Add app** → Android).
2. Android package name: `in.mayankjoshi.admin`  (must match exactly — set in `android/app/build.gradle.kts`)
3. App nickname: `MJ Admin Android`
4. SHA-1 (optional): skip — not needed for App Distribution.
5. **Register app**.
6. **Skip** the "Download google-services.json" step — we don't use Firebase SDKs in the app, only App Distribution (which uses the CLI, no in-app config needed).
7. On the **Project settings → General → Your apps** page, copy the **App ID**. Looks like `1:123456789012:android:abcdef0123456789012345`.

## 3. Register the iOS app (~2 min)

1. **Add app** → iOS.
2. Apple bundle ID: `in.mayankjoshi.admin`  (must match — set in `ios/Runner.xcodeproj/project.pbxproj`)
3. App nickname: `MJ Admin iOS`
4. **Register app**, skip the GoogleService-Info.plist download.
5. Copy the iOS **App ID** from Project settings → General.

## 4. Enable App Distribution + add yourself as tester

1. Left nav → **Run** → **App Distribution**. Click **Get started** for each app.
2. **Testers & groups** tab → **Add group** → name it `admins`.
3. **Add testers** → enter `consciousmayank@gmail.com` → assign to `admins`.
4. You'll get a verification email — accept it.

## 5. Install the Firebase CLI on your laptop

```bash
npm install -g firebase-tools     # requires Node 18+
firebase --version                # confirm
firebase login                    # browser flow, sign in as consciousmayank@gmail.com
```

## 6. Install the "App Tester" app on your phone

Open this on the phone you'll test from:
<https://appdistribution.firebase.dev/>

Sign in with the same Google account you added as a tester. Future builds appear automatically in the list.

## 7. Fill in `admin/.env`

```bash
cd admin
cp .env.example .env
$EDITOR .env
# Paste your two FIREBASE_*_APP_ID values from step 2 + 3.
# Leave FIREBASE_TESTER_GROUPS=admins (matches the group from step 4).
```

## 8. One-time Android keystore

```bash
./scripts/init-keystore.sh
# Pick a strong password — save it to a password manager.
# Back up android/keystore/release.jks + android/key.properties somewhere safe.
```

## 9. iOS signing (one-time, in Xcode)

```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select the **Runner** target → **Signing & Capabilities** tab.
2. Check **Automatically manage signing**.
3. Set **Team** to your Apple Developer team. (If you don't have one, enroll at <https://developer.apple.com/programs/>.)
4. Bundle Identifier should already say `in.mayankjoshi.admin`. If Apple says it's taken, change it AND update `ios/Runner.xcodeproj/project.pbxproj` AND re-register the iOS app in Firebase with the new ID.

---

## Releasing a new build

```bash
cd admin
./scripts/release.sh android        # → your phone within ~2 min
./scripts/release.sh ios            # iOS only
./scripts/release.sh both           # both platforms
```

The Firebase CLI uploads the binary, posts the release notes (defaults to the latest git commit subject), and emails everyone in the `admins` group with an install link.

To customize release notes for one specific build:
```bash
RELEASE_NOTES="Fixed the publish toggle on iOS landscape" ./scripts/release.sh android
```

---

## Troubleshooting

**`firebase appdistribution:distribute` fails with "App not found"**
→ Check `FIREBASE_ANDROID_APP_ID` / `FIREBASE_IOS_APP_ID` in `.env` matches what's in Firebase Console → Project settings → General.

**Phone says "Couldn't connect to server" after install**
→ The release APK lost its internet permission. Confirm `<uses-permission android:name="android.permission.INTERNET"/>` is in `android/app/src/main/AndroidManifest.xml` (not just under `src/debug/`).

**iOS build fails with "No signing certificate"**
→ Xcode → Runner target → Signing & Capabilities → set the Team. Make sure your Apple Developer enrollment is current.

**Phone can't reach the API after install**
→ Check the Settings screen in the app — `API_BASE_URL` should default to `https://mayankjoshi.in`. If not (e.g. you ran a dev build), change it there; it's stored in secure storage and survives restarts.
