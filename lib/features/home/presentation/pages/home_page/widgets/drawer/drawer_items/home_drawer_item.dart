import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Navigation item for the home drawer to go to the dashboard / main screen.
class HomeDrawerItem extends StatelessWidget {
  const HomeDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseListTile(
      title: 'Início'.hardcoded,
      platformIcon: PlatformIcon(
        materialIcon: Icons.home,
        cupertinoIcon: CupertinoIcons.home,
        color: context.theme.colorScheme.primary,
      ),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}
