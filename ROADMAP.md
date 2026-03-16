# WebBuddy Roadmap

## Phase 2 — Enhanced Blocking (High Priority)

### Android Native Request Interception
- Implement `WebViewClient.shouldInterceptRequest()` via platform channel
- Enable sub-resource blocking (scripts, images, iframes) on Android
- This is the single biggest improvement for ad blocking effectiveness

### iOS/macOS WKContentRuleList Integration
- Convert filter rules to WKContentRuleList JSON format
- Compile and attach to WKWebView configuration
- This enables OS-level blocking including sub-resources on Apple platforms

### Improved Filter List Management
- Download and cache EasyList/EasyPrivacy from official sources
- Auto-update filter lists on a configurable schedule
- Allow users to add custom filter list URLs
- Show filter list metadata (last updated, rule count)

## Phase 3 — Browser Features

### Find in Page
- Implement find-in-page overlay widget
- Use WebView `findAllAsync()` / `findNext()` APIs
- Highlight matches count

### Reader Mode
- Extract article content using Readability-style algorithm
- Display in clean, distraction-free layout
- Font size and theme controls for reader view

### File Downloads
- Implement proper download handling per platform
- Android: DownloadManager integration
- iOS: File sharing to Files app
- Progress tracking and notification

### Tab Persistence
- Save and restore open tabs across app restarts
- Store tab URLs and scroll positions

### Autofill from History/Bookmarks
- When typing in the omnibox, suggest matching history entries and bookmarks
- Rank by visit frequency and recency

## Phase 4 — Privacy Enhancements

### Per-Site Permission Controls
- UI to manage camera, microphone, location permissions per domain
- Store in SitePermissions table
- Show in page info sheet

### Phishing / Malicious URL Warning
- Integrate Google Safe Browsing API (or similar) for URL checking
- Show interstitial warning page for flagged URLs
- Allow user to proceed at their own risk

### Anti-Fingerprinting (Actual Implementation)
- Canvas fingerprinting mitigation (noise injection via platform channel)
- WebGL renderer string spoofing
- User-Agent normalization
- Requires native code on each platform — significant effort

### Cookie Jar Partitioning
- Implement first-party isolation for cookies
- Requires native WebView configuration per platform

### Do Not Track Header
- Inject DNT: 1 header on all requests
- Requires request header modification via platform channel

## Phase 5 — UX Polish

### Tab Previews
- Capture tab screenshots for tab switcher grid
- Use WebView screenshot APIs

### Gesture Navigation
- Swipe left/right for back/forward on mobile
- Pull-to-refresh gesture

### Share Extensions
- Share URLs to WebBuddy from other apps
- Handle deep links

### Sync (Optional, Privacy-Conscious)
- End-to-end encrypted bookmark and settings sync
- No server-side data access
- Optional — users can remain fully local

### Keyboard Shortcuts (Desktop)
- Cmd/Ctrl+T: New tab
- Cmd/Ctrl+W: Close tab
- Cmd/Ctrl+L: Focus address bar
- Cmd/Ctrl+Shift+T: Reopen closed tab

## Phase 6 — Platform Expansion

### Windows WebView2 Full Integration
- Bundle or require WebView2 runtime
- Register file associations for .html
- Integrate with Windows notification system

### Linux WebView
- Evaluate webview_linux or CEF-based solutions
- May require custom platform view implementation

### Web Platform (Experimental)
- Obviously cannot embed a webview in web
- Could serve as a bookmarks/history manager with sync

## Phase 7 — Advanced Features

### Extension API (Long-term)
- Define a minimal extension API for:
  - Content scripts (CSS injection)
  - Background rule processing
  - Custom filter lists
- This is a massive undertaking — scoped carefully

### Password Manager Integration
- Detect login forms
- Offer to save credentials in secure storage
- Autofill support

### Developer Tools
- Basic page source viewer
- Console log viewer
- Network request log (builds on existing blocked request tracking)

## Non-Goals

These are explicitly out of scope:

- **Building a rendering engine**: WebBuddy uses platform WebViews exclusively
- **Full Chromium/Gecko feature parity**: Not possible in a Flutter wrapper
- **VPN/Tor integration**: Out of scope; users can use OS-level VPN
- **Cryptocurrency wallet**: Not relevant to browser mission
- **Social features**: No built-in social media or messaging
