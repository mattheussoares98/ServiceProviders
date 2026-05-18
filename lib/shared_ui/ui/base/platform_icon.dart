import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A premium, adaptive platform-specific icon widget.
///
/// Automatically selects and styles the icon depending on whether the platform
/// uses Cupertino styling (iOS, macOS) or Material styling (Android, Web, Windows, etc.).
class PlatformIcon extends StatelessWidget {
  const PlatformIcon({
    super.key,
    required this.materialIcon,
    required this.cupertinoIcon,
    this.color,
    this.size,
    this.materialPadding,
    this.cupertinoPadding,
  });

  factory PlatformIcon.back({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.arrow_back,
        cupertinoIcon: CupertinoIcons.back,
        color: color,
        size: size,
      );

  factory PlatformIcon.share({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.share,
        cupertinoIcon: CupertinoIcons.share,
        color: color,
        size: size,
      );

  factory PlatformIcon.settings({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.settings,
        cupertinoIcon: CupertinoIcons.settings,
        color: color,
        size: size,
      );

  factory PlatformIcon.edit({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.edit,
        cupertinoIcon: CupertinoIcons.pencil,
        color: color,
        size: size,
      );

  factory PlatformIcon.delete({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.delete_outline,
        cupertinoIcon: CupertinoIcons.trash,
        color: color,
        size: size,
      );

  factory PlatformIcon.info({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.info_outline,
        cupertinoIcon: CupertinoIcons.info,
        color: color,
        size: size,
      );
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? materialPadding;
  final EdgeInsetsGeometry? cupertinoPadding;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtil.isCupertino) {
      final iconWidget = Icon(cupertinoIcon, color: color, size: size);
      return cupertinoPadding != null
          ? Padding(padding: cupertinoPadding!, child: iconWidget)
          : iconWidget;
    } else {
      final iconWidget = Icon(materialIcon, color: color, size: size);
      return materialPadding != null
          ? Padding(padding: materialPadding!, child: iconWidget)
          : iconWidget;
    }
  }
}
