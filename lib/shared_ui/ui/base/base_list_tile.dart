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
  });

  final String title;
  final PlatformIcon platformIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leadingWidget = SizedBox(
      width: Sizes.p48,
      height: Sizes.p48,
      child: platformIcon,
    );

    if (PlatformUtil.isCupertino) {
      return CupertinoListTile(
        title: BaseText(title),
        leading: leadingWidget,
        onTap: onTap,
      );
    } else {
      return ListTile(
        title: BaseText(title),
        leading: leadingWidget,
        onTap: onTap,
      );
    }
  }
}
