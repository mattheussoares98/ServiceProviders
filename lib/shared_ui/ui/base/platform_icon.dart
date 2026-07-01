import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
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
    this.isSmall = false,
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
  factory PlatformIcon.add({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.add,
        cupertinoIcon: CupertinoIcons.add,
        color: color,
        size: size,
      );

  factory PlatformIcon.delete({Key? key, Color? color, double? size}) =>
      PlatformIcon(
        key: key,
        materialIcon: Icons.delete_outline,
        cupertinoIcon: CupertinoIcons.trash,
        color: color ?? Colors.red,
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
  final bool isSmall;

  PlatformIcon copyWith({
    IconData? materialIcon,
    IconData? cupertinoIcon,
    Color? color,
    double? size,
    bool? isSmall,
  }) {
    return PlatformIcon(
      materialIcon: materialIcon ?? this.materialIcon,
      cupertinoIcon: cupertinoIcon ?? this.cupertinoIcon,
      color: color ?? this.color,
      size: size ?? this.size,
      isSmall: isSmall ?? this.isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Icon(
        context.isCupertino ? cupertinoIcon : materialIcon,
        color: color ?? AppColors.primaryLight,
        size: isSmall ? 16 : size,
      ),
    );
  }
}
