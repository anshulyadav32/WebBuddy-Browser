# Release Checklist — WebBuddy Beta

Use this checklist before publishing a beta release on any platform.

---

## Pre-Release Validation

### Code Quality
- [ ] `flutter analyze` passes with no errors or warnings
- [ ] `flutter test` — all unit, widget, and stability tests pass
- [ ] Integration tests pass on flutter-tester: `flutter test integration_test/<file> -d flutter-tester`
- [ ] No `print()`, `debugPrint()`, or verbose logging in `lib/`
- [ ] No hardcoded API keys, secrets, or credentials in source

### Platform Build Verification
- [ ] Android: `flutter build apk --release` succeeds
- [ ] Android: `flutter build appbundle --release` succeeds
- [ ] iOS: `flutter build ios --release` succeeds (requires signing)
- [ ] macOS: `flutter build macos --release` succeeds
- [ ] Windows: `flutter build windows --release` succeeds (if applicable)

### Manual Smoke Testing per Platform

Perform on **each target platform** (Android, iOS, macOS at minimum):

- [ ] App launches without crash
- [ ] Onboarding flow completes (first-run screen → main browser)
- [ ] URL navigation works (type URL → page loads)
- [ ] Search query works (type search term → search engine results)
- [ ] Back / forward / reload buttons function
- [ ] Tab creation, switching, and closing work
- [ ] Private tab shows badge, does not persist history
- [ ] Closing last private tab clears session data
- [ ] Bookmarks screen opens (empty state or with data)
- [ ] History screen opens (empty state or with data)
- [ ] Downloads screen opens (empty state)
- [ ] Settings screen opens, all toggles respond
- [ ] Shields panel opens, shows blocked count
- [ ] Error view appears for invalid URLs (e.g., `https://this-domain-does-not-exist.test`)
- [ ] App recovers from error view via "Try again"
- [ ] No ANR / UI freeze during normal browsing

---

## Android-Specific

### Configuration
- [ ] `android/app/build.gradle.kts`: `minSdk` ≥ 21, `targetSdk` ≥ 34
- [ ] `android/app/src/main/AndroidManifest.xml`: INTERNET permission declared
- [ ] ProGuard / R8 rules do not strip required classes
- [ ] App icon and splash screen configured

### Privacy
- [ ] Data safety declaration prepared for Play Store
- [ ] No unnecessary permissions requested

### Testing
- [ ] Tested on Android 12+ physical device
- [ ] Tested on Android 8 or 9 emulator (minimum SDK verification)
- [ ] WebView renders correctly in both light and dark system themes

---

## iOS-Specific

### Configuration
- [ ] `ios/Runner/Info.plist`: Required `NSAppTransportSecurity` keys set
- [ ] Deployment target ≥ iOS 14.0
- [ ] App icon assets provided for all required sizes
- [ ] Launch storyboard configured

### Signing
- [ ] Valid provisioning profile for distribution
- [ ] App ID registered in Apple Developer portal
- [ ] Entitlements file correct (no unnecessary capabilities)

### Testing
- [ ] Tested on iPhone (physical) with latest iOS
- [ ] Tested on iPad (simulator or physical)
- [ ] WKWebView security prompts handled gracefully

---

## macOS-Specific

### Configuration
- [ ] `macos/Runner/Info.plist`: Network entitlement enabled
- [ ] `macos/Runner/*.entitlements`: `com.apple.security.network.client` = true
- [ ] Deployment target ≥ macOS 10.14
- [ ] App icon provided
- [ ] Hardened runtime enabled for distribution

### Signing
- [ ] Developer ID certificate (for direct distribution) or
- [ ] Mac App Store provisioning profile (for App Store)
- [ ] Notarization passes (if distributing outside App Store)

### Testing
- [ ] Tested on Apple Silicon (arm64)
- [ ] Tested on Intel Mac (if supporting x86_64)
- [ ] Window resizing does not break layout
- [ ] Keyboard shortcuts work (Cmd+T, Cmd+W, Cmd+L)

---

## Windows-Specific

### Configuration
- [ ] WebView2 Runtime bundled or runtime check implemented
- [ ] Placeholder UI shown when WebView2 is unavailable
- [ ] MSIX packaging configured (if distributing via Store)

### Testing
- [ ] Tested on Windows 10 (build 1803+)
- [ ] Tested on Windows 11
- [ ] App launches and shows placeholder or WebView correctly

---

## Documentation

- [ ] `README.md` reflects current feature set and instructions
- [ ] `ROADMAP.md` updated with completed phases
- [ ] `KNOWN_LIMITATIONS.md` reviewed and accurate
- [ ] `TESTING.md` documents all test categories and how to run them
- [ ] `RELEASE_CHECKLIST.md` (this file) reviewed for completeness

---

## Release Artifacts

- [ ] Version number bumped in `pubspec.yaml`
- [ ] Changelog / release notes written
- [ ] Git tag created: `git tag -a v0.1.0-beta -m "Beta release"`
- [ ] Build artifacts archived (APK, IPA, .app, .msix as applicable)
- [ ] Screenshots captured for store listings (if applicable)

---

## Post-Release

- [ ] Monitor crash reports (if analytics/crash reporting is integrated)
- [ ] Collect beta tester feedback
- [ ] File issues for any new bugs discovered
- [ ] Update roadmap with findings from beta testing
