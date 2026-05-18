import 'dart:io' show Platform;
import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformUtil Unit Tests', () {
    test('isWeb should be false in a standard Flutter unit test environment', () {
      expect(PlatformUtil.isWeb, isFalse);
    });

    test('isAndroid should match Platform.isAndroid', () {
      expect(PlatformUtil.isAndroid, Platform.isAndroid);
    });

    test('isIOS should match Platform.isIOS', () {
      expect(PlatformUtil.isIOS, Platform.isIOS);
    });

    test('isMacOS should match Platform.isMacOS', () {
      expect(PlatformUtil.isMacOS, Platform.isMacOS);
    });

    test('isWindows should match Platform.isWindows', () {
      expect(PlatformUtil.isWindows, Platform.isWindows);
    });

    test('isLinux should match Platform.isLinux', () {
      expect(PlatformUtil.isLinux, Platform.isLinux);
    });

    test('isCupertino should match (isIOS || isMacOS)', () {
      expect(PlatformUtil.isCupertino, Platform.isIOS || Platform.isMacOS);
    });

    test('isMobile should match (isAndroid || isIOS)', () {
      expect(PlatformUtil.isMobile, Platform.isAndroid || Platform.isIOS);
    });

    test('isDesktop should match (isMacOS || isWindows || isLinux)', () {
      expect(PlatformUtil.isDesktop, Platform.isMacOS || Platform.isWindows || Platform.isLinux);
    });
  });
}
