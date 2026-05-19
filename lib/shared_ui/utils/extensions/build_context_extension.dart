import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension BuildContextExtension on BuildContext {
  double get statusHeight => MediaQuery.of(this).viewPadding.top;

  SystemUiOverlayStyle get systemOverlayStyle =>
      Theme.of(this).appBarTheme.systemOverlayStyle!;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  ThemeData get theme => Theme.of(this);

  bool get isCupertino => PlatformUtil.isCupertino;
}
