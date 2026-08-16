import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class PermissionItem extends StatelessWidget {
  const PermissionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.leading,
  });
  final String title;
  final Widget subtitle;
  final VoidCallback? onTap;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    final canEditUsers = context.hasPermission(
      const ActionPermission.resource(
        resourceType: ResourceType.users,
        permissionAction: PermissionAction.update,
      ),
    );

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p8),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            leading,
            gapH12,
            BaseText.title(title),
            subtitle,
            Align(
              alignment: .centerRight,
              child: BaseIconButton(
                onPressed: canEditUsers ? onTap : null,
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.edit,
                  cupertinoIcon: CupertinoIcons.pencil,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
