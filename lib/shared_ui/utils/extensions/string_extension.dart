/// Extension on [String] to provide utility methods and helper markers.
extension StringExtension on String {
  /// A marker extension used to explicitly identify hardcoded strings
  /// in the codebase. This helps maintain high development velocity
  /// for single-language releases while making it easy to find and
  /// extract strings for localization (i18n) in the future.
  String get hardcoded => this;
}
