import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/change_password/widgets/update_password_dialog.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class ProviderChangePasswordDrawerItem extends StatelessWidget {
  const ProviderChangePasswordDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseDrawerItem(
      title: 'Alterar senha'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.lock_outline,
        cupertinoIcon: CupertinoIcons.lock,
      ),
      onTap: () => UpdatePasswordDialog.show(context),
    );
  }
}
