import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_drawer_item.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Navigation item for the home drawer to go to the profile settings screen.
class ProfileDrawerItem extends StatelessWidget {
  const ProfileDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      title: 'Perfil'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.person_outline,
        cupertinoIcon: CupertinoIcons.person,
      ),
      onTap: () {},
    );
  }
}
