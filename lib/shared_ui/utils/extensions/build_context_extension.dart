import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension BuildContextExtension on BuildContext {
  double get statusHeight => MediaQuery.of(this).viewPadding.top;

  SystemUiOverlayStyle get systemOverlayStyle =>
      Theme.of(this).appBarTheme.systemOverlayStyle!;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isCupertino =>
      Theme.of(this).platform == TargetPlatform.iOS ||
      Theme.of(this).platform == TargetPlatform.macOS;
}
