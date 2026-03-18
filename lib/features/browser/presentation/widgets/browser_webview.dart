import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:webview_windows/webview_windows.dart' as ww;

import '../../../privacy/presentation/shields_controller.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../platform/platform_webview_controller.dart';
import '../browser_controller.dart';

// ── Platform adapters ────────────────────────────────────────────────────────

class _FlutterWebViewAdapter implements PlatformWebViewController {
  _FlutterWebViewAdapter(this._c);
  final wf.WebViewController _c;

  @override
  Future<void> loadUrl(String url) => _c.loadRequest(Uri.parse(url));
  @override
  Future<void> goBack() => _c.goBack();
  @override
  Future<void> goForward() => _c.goForward();
  @override
  Future<void> reload() => _c.reload();
  @override
  Future<void> stopLoading() => _c.runJavaScript('window.stop()');
  @override
  Future<bool> canGoBack() => _c.canGoBack();
  @override
  Future<bool> canGoForward() => _c.canGoForward();
  @override
  Future<String?> getTitle() => _c.getTitle();
  @override
  Future<void> runJavaScript(String script) => _c.runJavaScript(script);
  @override
  Future<String?> runJavaScriptReturningResult(String script) async {
    final result = await _c.runJavaScriptReturningResult(script);
    return result.toString();
  }
}

class _WindowsWebViewAdapter implements PlatformWebViewController {
  _WindowsWebViewAdapter(this._c);
  final ww.WebviewController _c;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String? _title;

  void updateHistory(bool back, bool fwd) {
    _canGoBack = back;
    _canGoForward = fwd;
  }

  void updateTitle(String title) => _title = title;

  @override
  Future<void> loadUrl(String url) => _c.loadUrl(url);
  @override
  Future<void> goBack() => _c.goBack();
  @override
  Future<void> goForward() => _c.goForward();
  @override
  Future<void> reload() => _c.reload();
  @override
  Future<void> stopLoading() => _c.stop();
  @override
  Future<bool> canGoBack() async => _canGoBack;
  @override
  Future<bool> canGoForward() async => _canGoForward;
  @override
  Future<String?> getTitle() async => _title;
  @override
  Future<void> runJavaScript(String script) async =>
      await _c.executeScript(script);
  @override
  Future<String?> runJavaScriptReturningResult(String script) async {
    final result = await _c.executeScript(script);
    return result.toString();
  }
}

// ── Widget ───────────────────────────────────────────────────────────────────

/// Wraps the platform WebView and wires callbacks to [BrowserController].
class BrowserWebView extends ConsumerStatefulWidget {
  const BrowserWebView({super.key});

  @override
  ConsumerState<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends ConsumerState<BrowserWebView> {
  // Non-Windows (webview_flutter)
  wf.WebViewController? _flutterController;

  // Windows (webview_windows)
  ww.WebviewController? _winController;
  bool _windowsReady = false;
  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      _initWindows();
    } else {
      _initFlutter();
    }
  }

  // ── Flutter (non-Windows) ───────────────────────────────────────────

  void _initFlutter() {
    final browserCtrl = ref.read(browserControllerProvider.notifier);
    final initialUrl = ref.read(browserControllerProvider).currentUrl;
    final settings = ref.read(settingsControllerProvider);
    final shieldsCtrl = ref.read(shieldsControllerProvider.notifier);

    _flutterController = wf.WebViewController()
      ..setJavaScriptMode(
        settings.javaScriptEnabled
            ? wf.JavaScriptMode.unrestricted
            : wf.JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        wf.NavigationDelegate(
          onPageStarted: (url) {
            browserCtrl.onPageStarted(url);
            shieldsCtrl.setCurrentPage(url);
          },
          onPageFinished: (url) {
            browserCtrl.onPageFinished(url);
            _injectCosmeticFilters(url);
            _applyRuntimeViewOptions();
            _injectContextMenuBridge();
          },
          onProgress: browserCtrl.onProgress,
          onUrlChange: (change) => browserCtrl.onUrlChange(change.url),
          onWebResourceError: (err) => browserCtrl.onWebResourceError(
            err.description,
            errorCode: err.errorCode,
            isForMainFrame: err.isForMainFrame ?? true,
          ),
          onNavigationRequest: (request) {
            if (settings.popUpBlockingEnabled && !request.isMainFrame) {
              return wf.NavigationDecision.prevent;
            }
            final pageUrl = ref.read(browserControllerProvider).currentUrl;
            final decision = shieldsCtrl.evaluateRequest(
              requestUrl: request.url,
              pageUrl: pageUrl,
            );
            if (decision.shouldBlock) return wf.NavigationDecision.prevent;
            return wf.NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'WebBuddyContextMenu',
        onMessageReceived: (message) {
          try {
            final decoded = jsonDecode(message.message) as Map<String, dynamic>;
            final targetUrl = (decoded['url'] as String?)?.trim();
            final type = (decoded['type'] as String?)?.trim();
            if (targetUrl != null && targetUrl.isNotEmpty) {
              browserCtrl.setLongPressTarget(targetUrl, type ?? 'link');
            }
          } catch (_) {
            // Ignore malformed page data.
          }
        },
      )
      ..loadRequest(Uri.parse(initialUrl));

    final customUa = settings.customUserAgent.trim();
    if (customUa.isNotEmpty) {
      _flutterController!.setUserAgent(customUa);
    }
    if (!settings.cacheEnabled) {
      _flutterController!.clearCache();
    }

    final adapter = _FlutterWebViewAdapter(_flutterController!);
    browserCtrl.attachWebView(adapter);
  }

  // ── Windows ─────────────────────────────────────────────────────────

  Future<void> _initWindows() async {
    final browserCtrl = ref.read(browserControllerProvider.notifier);
    final initialUrl = ref.read(browserControllerProvider).currentUrl;
    final shieldsCtrl = ref.read(shieldsControllerProvider.notifier);
    final settings = ref.read(settingsControllerProvider);

    final winCtrl = ww.WebviewController();
    await winCtrl.initialize();

    if (!mounted) {
      winCtrl.dispose();
      return;
    }

    final adapter = _WindowsWebViewAdapter(winCtrl);
    _winController = winCtrl;

    _subs.add(
      winCtrl.historyChanged.listen((h) {
        adapter.updateHistory(h.canGoBack, h.canGoForward);
      }),
    );

    _subs.add(
      winCtrl.title.listen((title) {
        adapter.updateTitle(title);
      }),
    );

    _subs.add(
      winCtrl.url.listen((url) {
        if (mounted) {
          browserCtrl.onUrlChange(url);
        }
      }),
    );

    _subs.add(
      winCtrl.loadingState.listen((state) {
        if (!mounted) return;
        final currentUrl = ref.read(browserControllerProvider).currentUrl;
        if (state == ww.LoadingState.loading) {
          browserCtrl.onPageStarted(currentUrl);
          shieldsCtrl.setCurrentPage(currentUrl);
        } else if (state == ww.LoadingState.navigationCompleted) {
          browserCtrl.onPageFinished(currentUrl);
          _injectCosmeticFilters(currentUrl);
        }
      }),
    );

    _subs.add(
      winCtrl.onLoadError.listen((error) {
        if (!mounted) return;
        browserCtrl.onWebResourceError(error.toString(), isForMainFrame: true);
      }),
    );

    // Disable JavaScript if needed (best-effort via script injection)
    if (!settings.javaScriptEnabled) {
      // webview_windows does not expose a JS toggle; this is a known limitation.
    }

    browserCtrl.attachWebView(adapter);
    await winCtrl.loadUrl(initialUrl);

    if (mounted) setState(() => _windowsReady = true);
  }

  // ── Cosmetic filter injection ────────────────────────────────────────

  void _injectCosmeticFilters(String pageUrl) {
    final shieldsCtrl = ref.read(shieldsControllerProvider.notifier);
    final script = shieldsCtrl.buildCosmeticInjectionScript(pageUrl);
    if (script != null) {
      if (Platform.isWindows) {
        _winController?.executeScript(script);
      } else {
        _flutterController?.runJavaScript(script);
      }
    }
  }

  void _applyRuntimeViewOptions() {
    final settings = ref.read(settingsControllerProvider);
    if (!settings.scrollbarsEnabled) {
      const hideScrollbarsScript = '''
        (() => {
          const styleId = 'webbuddy-hide-scrollbars';
          if (document.getElementById(styleId)) return;
          const style = document.createElement('style');
          style.id = styleId;
          style.textContent = '* { scrollbar-width: none !important; } ::-webkit-scrollbar { width: 0 !important; height: 0 !important; }';
          document.head.appendChild(style);
        })();
      ''';
      if (Platform.isWindows) {
        _winController?.executeScript(hideScrollbarsScript);
      } else {
        _flutterController?.runJavaScript(hideScrollbarsScript);
      }
    }
  }

  void _injectContextMenuBridge() {
    if (Platform.isWindows) {
      return;
    }
    const script = '''
      (() => {
        if (window.__webBuddyContextInstalled) return;
        window.__webBuddyContextInstalled = true;
        document.addEventListener('contextmenu', function(event) {
          let link = event.target && event.target.closest ? event.target.closest('a[href]') : null;
          let image = event.target && event.target.closest ? event.target.closest('img[src]') : null;
          let payload = null;
          if (image && image.src) {
            payload = { type: 'image', url: image.src };
          } else if (link && link.href) {
            payload = { type: 'link', url: link.href };
          }
          if (payload && window.WebBuddyContextMenu && window.WebBuddyContextMenu.postMessage) {
            event.preventDefault();
            window.WebBuddyContextMenu.postMessage(JSON.stringify(payload));
          }
        }, true);
      })();
    ''';
    _flutterController?.runJavaScript(script);
  }

  // ── Lifecycle ────────────────────────────────────────────────────────

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _winController?.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      if (!_windowsReady || _winController == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return ww.Webview(_winController!);
    }

    if (_flutterController == null) return const SizedBox.shrink();
    return wf.WebViewWidget(controller: _flutterController!);
  }
}
