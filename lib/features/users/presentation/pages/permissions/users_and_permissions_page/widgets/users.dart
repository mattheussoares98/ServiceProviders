import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/users_and_permissions_page/widgets/permission_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class Users extends StatelessWidget {
  const Users({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseStateView<UsersCubit, UsersState, List<UserProfileEntity>>(
      dataSelector: (state) => state.users,
      onRetry: () => context.read<UsersCubit>().loadAll(emitLoading: false),
      builder: (context, users) {
        if (users.isEmpty) {
          return Center(child: BaseText('Nenhum usuário cadastrado'.hardcoded));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(Sizes.p16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final groupName =
                context
                    .read<UsersCubit>()
                    .state
                    .permissionGroups
                    .firstWhereOrNull((e) => e.id == user.permissionGroupId)
                    ?.name ??
                'Sem grupo'.hardcoded;
            return PermissionItem(
              title: user.name,
              subtitle:
                  '${user.email} • ${user.isAdmin ? "Administrador" : groupName}'
                      .hardcoded,
              onTap: () => context
                  .read<UsersCubit>()
                  .navigateToEditUserPermissions(user),
              platformIcon: const PlatformIcon(
                materialIcon: Icons.person,
                cupertinoIcon: CupertinoIcons.person,
              ),
            );
          },
        );
      },
    );
  }
}
