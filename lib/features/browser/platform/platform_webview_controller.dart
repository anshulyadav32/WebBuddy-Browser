/// Platform-agnostic WebView controller interface.
///
/// Implementations:
/// - [FlutterWebViewAdapter]  – wraps `webview_flutter` (Android / iOS / Web)
/// - [WindowsWebViewAdapter]  – wraps `webview_windows`  (Windows desktop)
abstract class PlatformWebViewController {
  Future<void> loadUrl(String url);
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();
  Future<void> stopLoading();
  Future<bool> canGoBack();
  Future<bool> canGoForward();
  Future<String?> getTitle();
  Future<void> runJavaScript(String script);
  Future<String?> runJavaScriptReturningResult(String script);
}
