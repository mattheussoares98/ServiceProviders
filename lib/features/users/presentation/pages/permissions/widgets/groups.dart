import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_list_tile.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_state_view.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Groups extends StatelessWidget {
  const Groups({super.key});
  //TODO review
  @override
  Widget build(BuildContext context) {
    return BaseStateView<UsersCubit, UsersState, List<PermissionGroupEntity>>(
      dataSelector: (state) => state.permissionGroups,
      onRetry: () => context.read<UsersCubit>().loadAll(emitLoading: false),
      builder: (context, permissionGroups) {
        if (permissionGroups.isEmpty) {
          return Center(
            child: BaseText('Nenhum grupo de permissão cadastrado'.hardcoded),
          );
        }
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListView.builder(
          padding: const EdgeInsets.all(Sizes.p16),
          itemCount: permissionGroups.length,
          itemBuilder: (context, index) {
            final group = permissionGroups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: Sizes.p8),
              child: BaseListTile(
                title: group.name,
                subtitle: group.isDefault
                    ? 'Grupo padrão'.hardcoded
                    : '${group.permissions.length} recursos configurados'
                          .hardcoded,
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.security,
                  cupertinoIcon: CupertinoIcons.shield,
                ),
                tileColor: isDark ? AppColors.fadeLight : AppColors.black05,
                borderRadius: BorderRadius.circular(Sizes.p8),
                onTap: () {
                  context.router.push(EditGroupPermissionsRoute(group: group));
                },
              ),
            );
          },
        );
      },
    );
  }
}
