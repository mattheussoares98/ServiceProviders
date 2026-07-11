part of 'screen_util.dart';

/// Enum for categorizing device screen types based on logical screen width.
///
/// Categories are loosely inspired by Material Design 3 layout breakpoints:
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
///
/// Screen widths are in logical pixels (dp).
///
/// - [unknown]        : Screen type is not detected or supported.
/// - [compact]        : width <= 360 dp — very small phones.
/// - [phone]          : 361 dp to 600 dp — typical smartphones.
/// - [tablet]         : 601 dp to 840 dp — small/medium tablets.
/// - [largeTablet]    : 841 dp to 1024 dp — large tablets.
/// - [desktop]        : > 1024 dp — desktop or very large screen.

enum ScreenType {
  unknown(0),
  compact(360),
  phone(600),
  tablet(840),
  largeTablet(1024),
  desktop(1600);

  const ScreenType(this.maxWidth);
  final double maxWidth;
}
