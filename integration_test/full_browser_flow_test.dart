import 'regression_core_browser_flow_test.dart' as core_regression;

/// Full browser flow alias.
///
/// This test file intentionally reuses the validated core regression flow so
/// teams can run a clearly named "full browser flow" target in CI/release
/// pipelines without duplicating logic.
void main() {
  core_regression.main();
}
