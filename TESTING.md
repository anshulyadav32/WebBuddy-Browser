# Testing Guide

This document describes the testing strategy, test categories, and how to
run and extend the WebBuddy test suite.

---

## Test Categories

### Unit Tests (`test/`)

Pure logic tests that run without Flutter widgets. Cover:

- **Domain models**: Default values, `copyWith()`, serialization, equality
- **Controllers**: State transitions, edge cases, error handling
- **Utilities**: URL detection, domain extraction, filename derivation
- **Services**: Storage round-trips, clear browsing data logic
- **Privacy**: Filter rule parsing, blocking engine evaluation, third-party detection

Location: `test/core/`, `test/features/`, `test/unit/`

### Widget Tests (`test/widget/`)

Tests that pump Flutter widget trees with mocked providers. Cover:

- **Screen rendering**: Every top-level screen opens without crashing
- **Interactive behavior**: Button taps, toggle switches, text input
- **Conditional UI**: Private mode indicators, error views, empty states
- **Theme**: Components render correctly in light and dark themes

All widget tests use `ProviderScope` overrides with fake controllers that
do not require platform channels (WebView, cookies, file system).

### Stability / Hardening Tests (`test/stability/`)

Edge-case and resilience tests. Cover:

- **Invalid input**: Empty strings, extremely long strings, unicode, XSS payloads
- **Corrupt storage**: Missing keys, out-of-range enum indexes
- **Error states**: WebView errors, download failures, permission denials
- **Private mode cleanup**: Repeated cleanup calls, missing WebView controller
- **Smoke tests**: Every top-level screen renders without throwing

### Integration Tests (`integration_test/`)

End-to-end flow tests that exercise multi-screen user journeys. Cover:

- **Full browser flow** (Phase 1–9): Launch → tabs → bookmarks → history →
  private mode → settings → shields → error views → onboarding
- **Regression flow**: Tab lifecycle, empty states, toolbar rendering
- **Private mode flow**: Private tab creation → badge display → cleanup
- **Settings + shields flow**: Settings rendering, shields panel with stats
- **Tabs + bookmarks + history flow**: Cross-feature navigation

All integration tests use `IntegrationTestWidgetsFlutterBinding` and mock
platform dependencies.

---

## Running Tests

### All Unit + Widget + Stability Tests

```bash
flutter test
```

### Specific Test File

```bash
flutter test test/stability/hardening_edge_cases_test.dart
```

### Integration Tests (headless)

```bash
flutter test integration_test/regression_core_browser_flow_test.dart -d flutter-tester
```

### Integration Tests (on device)

```bash
flutter test integration_test/browser_phase_1_to_9_flow_test.dart -d macos
flutter test integration_test/browser_phase_1_to_9_flow_test.dart -d <device-id>
```

### All Integration Tests

```bash
for f in integration_test/*_test.dart; do
  flutter test "$f" -d flutter-tester
done
```

### Test Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Test File Inventory

| Category | Count | Location |
|----------|-------|----------|
| Unit (core) | 4 | `test/core/` |
| Unit (features) | 36 | `test/features/` |
| Unit (legacy) | 2 | `test/unit/` |
| Widget | 30 | `test/widget/` |
| Stability | 4 | `test/stability/` |
| Integration | 6 | `integration_test/` |
| **Total** | **82** | |

---

## Writing New Tests

### Conventions

1. **File naming**: `<feature>_<aspect>_test.dart`
2. **Group structure**: Outer `group()` per feature, inner `group()` per behavior
3. **Fake controllers**: Use `noSuchMethod => null` pattern for methods you don't test.
   Override specific methods (like `loadInput`) that return `Future<void>` explicitly.
4. **Provider overrides**: Always override `sharedPreferencesProvider`,
   `browserControllerProvider`, `shieldsControllerProvider`, and
   `siteSettingsControllerProvider` to avoid platform channel errors.
5. **Scrollable content**: Use `tester.scrollUntilVisible()` for items in
   `ListView` or `SingleChildScrollView` that may be off-screen.

### Common Patterns

**Fake BrowserController:**
```dart
class FakeBrowserController extends StateNotifier<BrowserPageState>
    implements BrowserController {
  FakeBrowserController() : super(const BrowserPageState());

  @override
  Future<void> loadInput(String input) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
```

**Base overrides helper:**
```dart
List<Override> baseOverrides(SharedPreferences prefs) => [
  sharedPreferencesProvider.overrideWithValue(prefs),
  browserControllerProvider.overrideWith((ref) => FakeBrowserController()),
  shieldsControllerProvider.overrideWith((_) => FakeShieldsController()),
  siteSettingsControllerProvider.overrideWith((_) => FakeSiteSettingsController()),
];
```

**Text in Text.rich:**
```dart
// Use find.textContaining() for Text.rich widgets, not find.text()
expect(find.textContaining('Tabs'), findsOneWidget);
```

---

## Known Test Limitations

- Integration tests use fake controllers — they do **not** test actual
  WebView rendering or network behavior.
- `PrivateDataManager.clearPrivateSessionData()` relies on
  `WebViewCookieManager` which cannot be fully mocked in unit tests
  without platform channel setup.
- Settings enum index deserialization does not clamp out-of-range values —
  this is documented as a stability test expectation.
