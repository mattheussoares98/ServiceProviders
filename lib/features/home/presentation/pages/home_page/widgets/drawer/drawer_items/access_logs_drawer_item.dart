import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class AccessLogsDrawerItem extends StatelessWidget {
  const AccessLogsDrawerItem({super.key});

  static const _accessLogsPermission = ActionPermission.resource(
    resourceType: ResourceType.accessLogs,
    permissionAction: PermissionAction.read,
  );

  @override
  Widget build(BuildContext context) {
    final canView = context.hasPermission(_accessLogsPermission);
    if (!canView) return const SizedBox.shrink();

    return BaseDrawerItem(
      onTap: context.read<HomeCubit>().navigateToAccessLogs,
      title: 'Logs de acesso'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.security_outlined,
        cupertinoIcon: CupertinoIcons.shield,
      ),
    );
  }
}
