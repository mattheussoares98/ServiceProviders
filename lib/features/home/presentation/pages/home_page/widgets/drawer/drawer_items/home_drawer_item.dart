import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_drawer_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Navigation item for the home drawer to go to the dashboard / main screen.
class HomeDrawerItem extends StatelessWidget {
  const HomeDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      title: 'Início'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.home,
        cupertinoIcon: CupertinoIcons.home,
      ),
      onTap: () {},
    );
  }
}
