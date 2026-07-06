import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

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
