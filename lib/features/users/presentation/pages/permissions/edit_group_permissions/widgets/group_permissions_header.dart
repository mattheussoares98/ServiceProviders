import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class GroupPermissionsHeader extends StatelessWidget {
  const GroupPermissionsHeader({
    super.key,
    required this.group,
    required this.isAdminGroup,
  });

  final PermissionGroupEntity group;
  final bool isAdminGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseText.titleMedium(group.name),
        gapH4,
        BaseText(
          group.isDefault
              ? 'Grupo de permissão padrão do sistema.'.hardcoded
              : 'Grupo de permissão personalizado.'.hardcoded,
          color: context.theme.hintColor,
        ),
        gapH16,
        if (isAdminGroup) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.p8),
              child: Row(
                children: [
                  const PlatformIcon(
                    materialIcon: Icons.info_outline,
                    cupertinoIcon: CupertinoIcons.info_circle,
                    color: Colors.orange,
                  ),
                  gapW12,
                  Expanded(
                    child: BaseText(
                      'Este é o grupo Administrador padrão. Ele possui acesso total irrestrito a todos os recursos do sistema e não pode ser editado.'
                          .hardcoded,
                    ),
                  ),
                ],
              ),
            ),
          ),
          gapH16,
        ],
      ],
    );
  }
}
