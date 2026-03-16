import 'package:logging/logging.dart';

/// Configures application-wide logging.
void setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('[${record.level.name}] ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('  Stack: ${record.stackTrace}');
    }
  });
}
