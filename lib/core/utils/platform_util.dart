import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// A centralized utility for safe, cross-platform platform detection.
///
/// This utility centralizes checks to ensure that they are completely safe
/// to run on the Web without throwing errors when referencing [Platform].
/// It also defines [isCupertino] to unify iOS and macOS Cupertino styling checks.
abstract final class PlatformUtil {
  static const bool isWeb = kIsWeb;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  static bool get isFuchsia => !kIsWeb && Platform.isFuchsia;
  static bool get isCupertino => isIOS || isMacOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isMacOS || isWindows || isLinux;
}
