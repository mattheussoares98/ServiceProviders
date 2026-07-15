import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride, kIsWeb;

/// A centralized utility for safe, cross-platform platform detection.
///
/// This utility centralizes checks to ensure that they are completely safe
/// to run on the Web without throwing errors when referencing [Platform].
/// It also defines [isCupertino] to unify iOS and macOS Cupertino styling checks.
abstract final class PlatformUtil {
  static const bool isWeb = kIsWeb;

  static bool get isAndroid =>
      !kIsWeb &&
      (debugDefaultTargetPlatformOverride == TargetPlatform.android ||
          (debugDefaultTargetPlatformOverride == null && Platform.isAndroid));

  static bool get isIOS =>
      !kIsWeb &&
      (debugDefaultTargetPlatformOverride == TargetPlatform.iOS ||
          (debugDefaultTargetPlatformOverride == null && Platform.isIOS));

  static bool get isMacOS =>
      !kIsWeb &&
      (debugDefaultTargetPlatformOverride == TargetPlatform.macOS ||
          (debugDefaultTargetPlatformOverride == null && Platform.isMacOS));

  static bool get isWindows =>
      !kIsWeb &&
      (debugDefaultTargetPlatformOverride == TargetPlatform.windows ||
          (debugDefaultTargetPlatformOverride == null && Platform.isWindows));

  static bool get isLinux =>
      !kIsWeb &&
      (debugDefaultTargetPlatformOverride == TargetPlatform.linux ||
          (debugDefaultTargetPlatformOverride == null && Platform.isLinux));

  static bool get isFuchsia =>
      !kIsWeb &&
      (debugDefaultTargetPlatformOverride == TargetPlatform.fuchsia ||
          (debugDefaultTargetPlatformOverride == null && Platform.isFuchsia));

  static bool get isCupertino => isIOS || isMacOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => isMacOS || isWindows || isLinux;
}
