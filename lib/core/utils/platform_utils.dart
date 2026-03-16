import 'dart:io';

import 'package:flutter/foundation.dart';

/// Platform detection utilities.
class PlatformUtils {
  PlatformUtils._();

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// Whether the platform supports the webview_flutter plugin.
  static bool get hasWebViewSupport => isAndroid || isIOS || isMacOS;

  // TODO: Windows WebView2 support requires webview_flutter_windows plugin
  // which is not yet stable. Track: https://pub.dev/packages/webview_flutter_windows
  static bool get hasPartialWebViewSupport => isWindows || isLinux;
}
