import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
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
    required this.platformIcon,
  });
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final PlatformIcon platformIcon;

  @override
  Widget build(BuildContext context) {
    final canEditUsers = context.hasPermission(
      const ActionPermission(
        resource: ResourceType.users,
        action: PermissionAction.update,
      ),
    );

    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: canEditUsers ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p8),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Sizes.p8),
                child: PlatformIcon(
                  materialIcon: Icons.person,
                  cupertinoIcon: CupertinoIcons.person,
                ),
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [BaseText.title(title), BaseText(subtitle)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
