# WebBuddy — Privacy-Focused Web Browser

A production-grade, privacy-focused web browser built with Flutter, using platform-native web engines for rendering and Flutter for all browser chrome, state management, and UI.

## Architecture Overview

```
┌──────────────────────────────────────────────────────┐
│                    Flutter UI Layer                    │
│  ┌──────────┬──────────┬──────────┬────────────────┐  │
│  │ Browser  │   Tabs   │ Settings │  Privacy/      │  │
│  │   Page   │ Switcher │   Page   │  Shields       │  │
│  └────┬─────┴────┬─────┴────┬─────┴───────┬────────┘  │
│       │          │          │             │            │
│  ┌────┴──────────┴──────────┴─────────────┴────────┐  │
│  │            Riverpod State Management             │  │
│  │  (Providers, Notifiers, Session State)           │  │
│  └────┬──────────┬──────────┬─────────────┬────────┘  │
│       │          │          │             │            │
│  ┌────┴────┐ ┌───┴───┐ ┌───┴───┐ ┌───────┴────────┐  │
│  │ Drift   │ │Secure │ │Filter │ │ Search/Omnibox  │  │
│  │Database │ │Storage│ │Engine │ │   Resolution    │  │
│  └─────────┘ └───────┘ └───────┘ └────────────────┘  │
├──────────────────────────────────────────────────────┤
│              Platform WebView Layer                    │
│  ┌──────────┬──────────┬──────────┬────────────────┐  │
│  │ Android  │   iOS/   │ Windows  │     Linux      │  │
│  │ WebView  │  macOS   │ WebView2 │   (Planned)    │  │
│  │(Chromium)│(WKWebView│          │                │  │
│  └──────────┴──────────┴──────────┴────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### Design Principles

- **Feature-based folder structure**: Each feature (browser, tabs, bookmarks, history, downloads, privacy, settings, search, onboarding) has data, domain, and presentation layers.
- **Dependency injection via Riverpod**: All state and services flow through typed providers for testability.
- **Platform-native WebViews**: Flutter does NOT render web content — it delegates to the OS web engine.
- **Privacy by default**: Ad/tracker blocking and HTTPS upgrade enabled out of the box.
- **Honest about limitations**: Every platform limitation is documented, not hidden.

## Supported Platforms

| Platform | WebView Engine | Status | Notes |
|----------|---------------|--------|-------|
| Android  | Android System WebView (Chromium) | ✅ Full | Best support via webview_flutter |
| iOS      | WKWebView | ✅ Full | WKContentRuleList for content blocking |
| macOS    | WKWebView | ✅ Full | Same engine as iOS |
| Windows  | WebView2 | ⚠️ Partial | Plugin exists but not bundled; placeholder UI shown |
| Linux    | — | ⚠️ Placeholder | No stable Flutter WebView plugin; shows placeholder |

## Implemented Features

### Browser Core
- [x] Multi-tab browsing with independent per-tab state
- [x] Tab switcher (grid view for mobile)
- [x] Desktop-style tab bar strip with drag-to-reorder
- [x] Address bar / omnibox with URL detection vs search query
- [x] Back, forward, refresh navigation controls
- [x] Loading progress indicator
- [x] HTTPS security indicator in address bar
- [x] New tab / close tab / close all / close others
- [x] Tab duplication

### Privacy & Security
- [x] Ad blocking via EasyList-style filter rule parsing
- [x] Tracker blocking with third-party detection
- [x] Filter engine with blocking rules, exception rules, and cosmetic rules
- [x] HTTPS upgrade (automatic http→https)
- [x] Per-site shields toggle
- [x] Shields badge showing blocked count per page
- [x] Shields panel with list of blocked request URLs and matched rules
- [x] Third-party cookie policy settings
- [x] JavaScript toggle
- [x] Pop-up blocking toggle
- [x] Anti-fingerprinting toggle (setting)
- [x] Incognito/private mode with separate session (no persistence)
- [x] Clear browsing data (history, cookies, cache, permissions)

### Data Management
- [x] Bookmarks with folder support
- [x] Browsing history with search and date grouping
- [x] Downloads manager with status tracking
- [x] Site permissions storage
- [x] Drift SQL database for all persistence
- [x] Secure storage for sensitive settings

### Search & Omnibox
- [x] URL vs search query detection
- [x] URL normalization (auto-add https://)
- [x] Multiple search engines (Google, DuckDuckGo, Bing, Brave Search)
- [x] Search suggestion fetching (OpenSearch JSON format)
- [x] Debounced search suggestions

### UI/UX
- [x] Light and dark themes
- [x] Custom browser theme extension (toolbar, tab bar, address bar colors)
- [x] Material 3 design
- [x] Onboarding flow (welcome, privacy info, search engine selection)
- [x] Empty states for bookmarks, history, downloads
- [x] Settings page with all privacy controls
- [x] Responsive: tab bar shown on desktop, hidden on mobile

## Ad & Tracker Blocking — How It Works

### Filter Rule Parsing

The filter engine parses Adblock Plus / EasyList syntax:

| Pattern | Example | Supported |
|---------|---------|-----------|
| Domain anchor | `\|\|ads.example.com^` | ✅ |
| Separator | `\|\|tracker.net^` | ✅ |
| Exception | `@@\|\|safe.com^` | ✅ |
| Third-party | `\|\|analytics.com^$third-party` | ✅ |
| Domain restriction | `\|\|ads.com^$domain=site.com` | ✅ |
| Cosmetic | `##.ad-banner` | ✅ (CSS injection) |
| Wildcard | `\|\|ads*.com^` | ✅ |
| Extended CSS | `#?#.ad:has(...)` | ❌ |
| Scriptlet injection | `##+js(...)` | ❌ |

### Blocking Pipeline

1. **Page navigations** are intercepted by `NavigationDelegate`
2. Intercepted URLs are checked against the filter engine
3. Exception rules (@@) are checked first — if matched, the request proceeds
4. Blocking rules are checked — if matched, the request is prevented
5. Blocked requests are logged for the shields panel
6. After page load, **cosmetic filter CSS** is injected to hide ad elements

### Platform Differences

- **Android**: `NavigationDelegate` intercepts main-frame navigations only. Sub-resource blocking (images, scripts) requires native `shouldInterceptRequest()` — a roadmap item.
- **iOS/macOS**: `WKContentRuleList` can block at the OS level including sub-resources. Integration is a roadmap item.
- **All platforms**: Cosmetic filters (element hiding via CSS) work everywhere via JS injection.

## Known Limitations

### Android
- Sub-resource request interception not available through Flutter's WebView plugin
- Content blocking limited to main-frame navigation + cosmetic CSS injection
- Full blocking needs native `WebViewClient.shouldInterceptRequest()`

### iOS / macOS
- WKContentRuleList integration is a roadmap item for native-level blocking
- File download handling requires native code for full support

### Windows
- WebView2 Flutter plugin not yet stable
- Shows placeholder UI; requires Edge WebView2 Runtime

### Linux
- No stable WebView plugin for Flutter
- Shows placeholder UI

### General
- Anti-fingerprinting is a setting flag; actual Canvas/WebGL/AudioContext spoofing is not possible without platform-level WebView API extensions
- Reader mode is a roadmap item
- Find in page requires WebView `findAllAsync()` support

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants, search engine configs
│   ├── di/              # Dependency injection providers
│   ├── error/           # Error type hierarchy
│   ├── extensions/      # String, URI extensions
│   ├── router/          # Named route definitions
│   ├── theme/           # Light/dark themes, BrowserThemeExtension
│   └── utils/           # URL utils, platform detection, logging
├── features/
│   ├── browser/         # Main browser page, WebView container, toolbar
│   ├── tabs/            # Tab model, session state, tab switcher
│   ├── bookmarks/       # Bookmark CRUD, folder support
│   ├── history/         # History recording, search, grouped list
│   ├── downloads/       # Download tracking, status display
│   ├── privacy/         # Filter engine, filter rules, shields
│   ├── settings/        # Settings model, persistence, UI
│   ├── search/          # Omnibox resolution, search suggestions
│   └── onboarding/      # First-run onboarding flow
├── shared/
│   └── data/database/   # Drift database with all tables
└── main.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK (stable channel, 3.11+)
- Android: Android Studio, Android SDK
- iOS/macOS: Xcode 15+
- Windows: Visual Studio 2022, WebView2 Runtime
- Linux: cmake, ninja-build, pkg-config, libgtk-3-dev

### Build & Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
flutter test
```

## Testing

67 tests across 6 test files:

| File | Tests | Coverage |
|------|-------|----------|
| `url_utils_test.dart` | 16 | URL detection, normalization, domain extraction, scheme detection |
| `filter_rule_test.dart` | 17 | Rule parsing (comments, domains, exceptions, cosmetic, options) |
| `filter_engine_test.dart` | 9 | Engine loading, blocking, exceptions, third-party, cosmetic selectors |
| `search_provider_test.dart` | 6 | Omnibox URL vs search resolution |
| `browser_tab_test.dart` | 10 | Tab creation, session state, equality |
| `settings_test.dart` | 4 | Defaults, copyWith, JSON serialization |
| `widget_test.dart` | 2 | Tab switcher widget rendering |

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `webview_flutter` | Platform WebView (Android, iOS, macOS) |
| `drift` + `sqlite3_flutter_libs` | SQL database |
| `http` | Search suggestions |
| `url_launcher` | External link handling |
| `share_plus` | System share sheet |
| `path_provider` | Local file paths |
| `permission_handler` | Runtime permissions |
| `flutter_secure_storage` | Encrypted settings storage |
| `uuid` | Unique IDs |
| `intl` | Date formatting |
| `logging` | Structured logging |

## License

MIT
