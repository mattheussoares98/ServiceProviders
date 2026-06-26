import 'package:clean_architecture/core/utils/platform_util.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A premium, adaptive platform-specific list tile.
///
/// Automatically renders either a [CupertinoListTile] or a Material [ListTile]
/// depending on whether the platform is iOS/macOS or Android/Web/Windows.
class BaseListTile extends StatelessWidget {
  const BaseListTile({
    super.key,
    required this.title,
    required this.platformIcon,
    this.onTap,
    this.subtitle,
    this.padding,
    this.tileColor,
    this.borderRadius,
  });

  final String title;
  final PlatformIcon platformIcon;
  final VoidCallback? onTap;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final Color? tileColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final leadingWidget = SizedBox(
      width: Sizes.p48,
      height: Sizes.p48,
      child: platformIcon,
    );

    if (PlatformUtil.isCupertino) {
      Widget tile = CupertinoListTile(
        padding: padding,
        title: BaseText(title),
        leading: leadingWidget,
        subtitle: subtitle != null ? BaseText(subtitle!) : null,
        onTap: onTap,
        backgroundColor: Colors.transparent,
      );
      if (tileColor != null || borderRadius != null) {
        tile = Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: borderRadius,
          ),
          child: tile,
        );
      }
      return tile;
    } else {
      return ListTile(
        contentPadding: padding,
        title: BaseText(title),
        leading: leadingWidget,
        subtitle: subtitle != null ? BaseText(subtitle!) : null,
        onTap: onTap,
        tileColor: tileColor,
        shape: borderRadius != null
            ? RoundedRectangleBorder(borderRadius: borderRadius!)
            : null,
      );
    }
  }
}
