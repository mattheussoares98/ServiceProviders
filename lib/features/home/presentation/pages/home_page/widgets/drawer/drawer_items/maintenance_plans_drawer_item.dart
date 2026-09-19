import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

/// Navigation item for the home drawer to go to the maintenance plans screen.
class MaintenancePlansDrawerItem extends StatelessWidget {
  const MaintenancePlansDrawerItem({super.key});

  static const _maintenancePlansPermission = ActionPermission.resource(
    resourceType: ResourceType.maintenancePlans,
    permissionAction: PermissionAction.read,
  );

  @override
  Widget build(BuildContext context) {
    final canView = context.hasPermission(_maintenancePlansPermission);
    if (!canView) return const SizedBox.shrink();

    return BaseDrawerItem(
      title: 'Planos de manutenção'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.calendar_month_outlined,
        cupertinoIcon: CupertinoIcons.calendar,
      ),
      onTap: context.read<HomeCubit>().navigateToMaintenancePlans,
    );
  }
}
