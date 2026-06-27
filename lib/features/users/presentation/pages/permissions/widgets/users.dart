import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
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

class Users extends StatelessWidget {
  const Users({super.key});
  //TODO review
  @override
  Widget build(BuildContext context) {
    return BaseStateView<UsersCubit, UsersState, List<UserProfileEntity>>(
      dataSelector: (state) => state.users,
      onRetry: () => context.read<UsersCubit>().loadAll(emitLoading: false),
      builder: (context, users) {
        if (users.isEmpty) {
          return Center(child: BaseText('Nenhum usuário cadastrado'.hardcoded));
        }
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListView.builder(
          padding: const EdgeInsets.all(Sizes.p16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final groupName = context
                .read<UsersCubit>()
                .state
                .permissionGroups
                .firstWhere(
                  (g) => g.id == user.permissionGroupId,
                  orElse: () => PermissionGroupEntity(
                    id: '',
                    companyId: '',
                    name: 'Sem Grupo'.hardcoded,
                    permissions: const [],
                    isDefault: false,
                    createdAt: DateTime.now(),
                  ),
                )
                .name;

            return Padding(
              padding: const EdgeInsets.only(bottom: Sizes.p8),
              child: BaseListTile(
                title: user.name,
                subtitle:
                    '${user.email} • ${user.isAdmin ? "Administrador" : groupName}'
                        .hardcoded,
                platformIcon: const PlatformIcon(
                  materialIcon: Icons.person,
                  cupertinoIcon: CupertinoIcons.person,
                ),
                tileColor: isDark ? AppColors.fadeLight : AppColors.black05,
                borderRadius: BorderRadius.circular(Sizes.p8),
                onTap: () {
                  context.router.push(EditUserPermissionsRoute(user: user));
                },
              ),
            );
          },
        );
      },
    );
  }
}
