# Known Limitations

WebBuddy is honest about what it can and cannot do. This document lists
platform constraints, plugin gaps, and intentional non-goals so that users
and contributors have clear expectations.

---

## Platform WebView Constraints

### Android — System WebView (Chromium)

| Area | Limitation | Impact |
|------|-----------|--------|
| Sub-resource blocking | `webview_flutter` does not expose `shouldInterceptRequest()` | Scripts, images, and XHR from ad/tracker domains cannot be individually blocked. Only main-frame navigations are intercepted. |
| Content rules | No native content-rule API available through the plugin | Cannot compile declarative blocking rules that run inside the WebView engine. |
| Find in page | `window.find()` JS API is unreliable on Android WebView | Find-in-page may not highlight matches on some Android versions. |
| File downloads | Full `DownloadManager` integration requires platform channels | Current implementation uses Dio for HTTP downloads; large files or system-level downloads are not managed by the OS download manager. |
| Cookie jar isolation | No separate cookie/storage partitioning per tab | Private mode clears data on session end but does not run in a truly isolated container. |

### iOS / macOS — WKWebView

| Area | Limitation | Impact |
|------|-----------|--------|
| WKContentRuleList | Integration is a roadmap item | OS-level blocking (including sub-resources) is possible but not yet implemented via the Flutter plugin. |
| Download handling | WKWebView download delegate requires native glue | File downloads are handled via Dio HTTP, not the native Safari download flow. |
| Cookie partitioning | No first-party isolation API exposed | Same limitation as Android regarding cross-tab cookie sharing. |
| Find in page | `window.find()` is partially supported | Works on most pages but may not highlight correctly in all cases. |

### Windows — WebView2

| Area | Limitation | Impact |
|------|-----------|--------|
| Plugin maturity | `webview_flutter` Windows support is not yet stable | WebBuddy shows a placeholder UI on Windows rather than a broken WebView. |
| Runtime dependency | Requires Microsoft Edge WebView2 Runtime | Users without the runtime will see a prompt to install it. |

### Linux

| Area | Limitation | Impact |
|------|-----------|--------|
| No WebView plugin | No stable Flutter WebView plugin exists for Linux | WebBuddy shows a placeholder UI on Linux. |

---

## Privacy & Security Constraints

### Anti-Fingerprinting

The anti-fingerprinting toggle in settings is a **preference flag only**.
Actual fingerprinting mitigations — Canvas noise injection, WebGL renderer
string spoofing, AudioContext fingerprinting defense — require native
platform code that modifies WebView behavior below the Flutter layer. This
is documented as a future roadmap item.

### Private / Incognito Mode

Private mode prevents **persistence** (no history saved, cookies/storage
cleared on tab close) but does **not** provide:

- Network-level privacy (user's IP is still visible)
- DNS encryption
- Separate browser process or profile isolation
- Protection from browser fingerprinting

This matches the behavior of "incognito" in major browsers — it is a
convenience feature, not a security guarantee.

### HTTPS Upgrade

The HTTPS upgrade feature prepends `https://` to URLs that lack a scheme.
It does **not**:

- Perform HSTS preloading
- Intercept and upgrade `http://` links clicked within pages
- Verify certificate chains beyond what the platform WebView does natively

### Ad / Tracker Blocking

The blocking engine is a best-effort MVP:

- **Parsed rules**: Domain-anchor, exception, third-party, and cosmetic
  rules from Adblock Plus / EasyList syntax.
- **Not parsed**: Extended CSS selectors (`#?#`), scriptlet injections
  (`##+js()`), resource-type filters (`$script`, `$image`).
- **Enforcement**: Navigation-level blocking + CSS injection for cosmetic
  rules. Sub-resource blocking requires platform extensions.

---

## UI / UX Constraints

### Share

Sharing is implemented via clipboard copy. There is no `share_plus`
integration. Users see a "Copied to clipboard" snackbar rather than
the native share sheet.

### Long-press Link Actions

The `webview_flutter` plugin does not expose a context-menu interception
API. Users cannot long-press a link to open it in a new tab, copy the
URL, or share it. This is a plugin limitation.

### Tab Previews

Tab previews (screenshot thumbnails in the tab switcher) require the
WebView screenshot API, which is not consistently available across all
platforms through the Flutter plugin.

### Reader Mode

Not implemented. Readability-style article extraction and rendering is
a roadmap item.

---

## Build & Deployment

### macOS Code Signing

Development builds may encounter code-signing issues when running
outside Xcode (e.g., via `flutter run`). Workaround:

```bash
xattr -cr build/
```

### Drift Database

The project uses `shared_preferences` for all persistence in the current
codebase. Drift (SQL) is declared in dependencies and directory structure
but full migration to Drift-backed storage is a roadmap item.

---

## Test Limitations

### Integration Tests

Integration tests use `flutter_test` with `IntegrationTestWidgetsFlutterBinding`
and mock all platform dependencies (WebView, cookie manager). They verify
UI flows but **do not** test actual web page loading, network requests, or
platform WebView behavior.

### WebView-Dependent Features

Features that depend on a running platform WebView (find-in-page, JavaScript
injection, cookie clearing, download interception) are tested via mock
controllers. End-to-end verification of these features requires manual
testing on each platform.
