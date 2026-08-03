import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class SectorsDrawerItem extends StatelessWidget {
  const SectorsDrawerItem({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.hasPermission(
      const ActionPermission.resource(
        resource: ResourceType.sectors,
        action: PermissionAction.read,
      ),
    )) {
      return const SizedBox.shrink();
    }

    return BaseDrawerItem(
      onTap: context.read<HomeCubit>().navigateToSectors,
      title: 'Setores'.hardcoded,
      platformIcon: const PlatformIcon(
        materialIcon: Icons.domain,
        cupertinoIcon: CupertinoIcons.building_2_fill,
      ),
    );
  }
}
