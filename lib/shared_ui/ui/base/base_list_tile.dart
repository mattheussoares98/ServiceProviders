import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

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
    this.trailing,
  });

  final String title;
  final PlatformIcon platformIcon;
  final VoidCallback? onTap;
  final String? subtitle;
  final EdgeInsetsGeometry? padding;
  final Color? tileColor;
  final BorderRadius? borderRadius;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final leadingWidget = SizedBox(
      width: Sizes.p48,
      height: Sizes.p48,
      child: platformIcon,
    );

    if (PlatformUtil.isCupertino) {
      Widget tile = CupertinoListTile(
        trailing: trailing,
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
        trailing: trailing,
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
