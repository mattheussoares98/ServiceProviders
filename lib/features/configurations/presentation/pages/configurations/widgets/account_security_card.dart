import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/pages/change_password/widgets/update_password_dialog.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/configuration_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class AccountSecurityCard extends StatelessWidget {
  const AccountSecurityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfigurationItem(
      platformIcon: const PlatformIcon(
        materialIcon: Icons.lock_outline,
        cupertinoIcon: CupertinoIcons.lock,
      ),
      title: 'Segurança da conta'.hardcoded,
      subtitle: 'Gerencie sua senha de acesso ao aplicativo'.hardcoded,
      actionWidget: BaseButton(
        onTap: () => UpdatePasswordDialog.show(context),
        text: 'Alterar senha'.hardcoded,
      ),
    );
  }
}
