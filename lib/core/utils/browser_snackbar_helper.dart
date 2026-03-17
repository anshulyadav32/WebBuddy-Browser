import 'package:flutter/material.dart';

/// Utility class for showing themed snackbars across the app.
///
/// All snackbars use Material 3 styling and auto-dismiss.
class BrowserSnackbarHelper {
  BrowserSnackbarHelper._();

  /// Shows a standard informational snackbar.
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: duration,
          action: action,
        ),
      );
  }

  /// Shows an error snackbar with error colouring.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onRetry,
  }) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: cs.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: duration,
          action: onRetry != null
              ? SnackBarAction(
                  label: 'Retry',
                  textColor: cs.onErrorContainer,
                  onPressed: onRetry,
                )
              : null,
        ),
      );
  }

  /// Shows a success snackbar with a brief confirmation.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: cs.onPrimaryContainer),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: cs.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: duration,
        ),
      );
  }
}
