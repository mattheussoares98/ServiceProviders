import 'dart:io';

/// Gate that keeps the live-Supabase suites out of an ordinary `flutter test`.
///
/// Tag-based exclusion cannot work here: `flutter test` has no way to re-include
/// a tag that `dart_test.yaml` excludes at the top level, so the suites would be
/// unrunnable. Instead every integration suite calls [registerGuard] as the first
/// statement of `main()`. When the flag is absent the suite registers **no
/// tests** — a bare `flutter test` reports "No tests ran" for these files and
/// stays green, while never opening a connection to production.
class IntegrationRun {
  const IntegrationRun._();

  static const _dartDefine = String.fromEnvironment('INTEGRATION_TESTS');

  /// True only when the runner script has opted this process in.
  static bool get enabled =>
      _dartDefine == 'true' ||
      Platform.environment['INTEGRATION_TESTS'] == 'true';

  /// Returns true when the caller should register its tests.
  ///
  /// Usage — the first line of every integration suite's `main()`:
  /// ```dart
  /// void main() {
  ///   if (!IntegrationRun.registerGuard()) return;
  ///   ...
  /// }
  /// ```
  static bool registerGuard() => enabled;

  /// Hard stop for code that would otherwise open a live connection.
  ///
  /// [registerGuard] already prevents this from being reached in a normal run;
  /// this is the backstop for a suite that forgets the guard.
  static void assertEnabled() {
    if (enabled) return;
    throw StateError(
      'Integration tests hit the live Supabase project and are disabled by '
      'default. Run them with tool/run_integration_tests.sh.',
    );
  }
}
