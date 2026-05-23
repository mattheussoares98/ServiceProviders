import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Navigation item for the home drawer to go to the global application settings screen.
class SettingsDrawerItem extends StatelessWidget {
  const SettingsDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseListTile(
      title: 'Configurações'.hardcoded,
      platformIcon: PlatformIcon(
        materialIcon: Icons.settings_outlined,
        cupertinoIcon: CupertinoIcons.settings,
        color: context.theme.colorScheme.primary,
      ),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}
