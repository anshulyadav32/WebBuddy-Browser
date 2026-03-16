import 'package:flutter/material.dart';

import '../../browser/presentation/widgets/browser_progress_bar.dart';
import '../../browser/presentation/widgets/browser_toolbar.dart';
import '../../browser/presentation/widgets/browser_webview.dart';

/// Main browser screen with toolbar, progress bar, and webview.
class BrowserHomeScreen extends StatelessWidget {
  const BrowserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          BrowserToolbar(),
          BrowserProgressBar(),
          Expanded(child: BrowserWebView()),
        ],
      ),
    );
  }
}
