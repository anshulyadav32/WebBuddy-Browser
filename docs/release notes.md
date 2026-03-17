# Release Notes

## Basic Browser 0.0.1

### New features
- Added offline page saving and offline page management.
- Added developer console support for running JavaScript on the current page.
- Added SSL and connection detail viewing.
- Added cookies and storage inspection tools.
- Added network insight actions and shields summary access.
- Added custom user-agent support.
- Added cache and scrollbar settings.
- Added configurable default home page support.
- Added long-press target actions for supported page content.
- Added updated Android, Windows, and iOS app icons.

### Improvements
- Moved reload into the address bar for faster access.
- Moved downloads, shields, and site info into the 3-dot actions menu.
- Improved tab card layout and toolbar compactness.
- Updated Android app identity and launcher label to `Basic Browser`.

### Fixes
- Fixed multiple compile errors across browser, privacy, downloads, and settings modules.
- Fixed onboarding flow and restored expected first-run navigation behavior.
- Fixed settings screen test and section visibility issues.
- Fixed page actions bottom sheet overflow.
- Fixed toolbar overflow on Android.
- Fixed test regressions caused by browser controller default URL updates.
- Fixed state handling around missing active tabs and related test expectations.
- Fixed app icon packaging for Android and Windows release builds.

### Verification
- Android debug run completed successfully.
- Android release APK built successfully.
- Full test suite passed during validation.