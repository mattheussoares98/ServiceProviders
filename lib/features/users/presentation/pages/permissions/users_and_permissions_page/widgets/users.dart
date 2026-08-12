import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/users_and_permissions_page/widgets/permission_item.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class Users extends StatelessWidget {
  const Users({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseStateView<UsersCubit, UsersState, List<UserProfileEntity>>(
      dataSelector: (state) => state.users,
      onRetry: () => context.read<UsersCubit>().loadAll(),
      sectionKey: UsersSections.loadAll,
      builder: (context, users) {
        if (users.isEmpty) {
          return Center(child: BaseText('Nenhum usuário cadastrado'.hardcoded));
        }
        users.sort((a, b) => a.name.compareTo(b.name));
        return ResponsiveListFlow(
          itemCount: users.length,
          maxItemWidth: 200,
          useMultiColumnWhenMobile: true,
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
            final roleOrGroup = user.isAdmin
                ? 'Administrador'.hardcoded
                : groupName;
            final statusLabel = user.isActive
                ? 'Ativo'.hardcoded
                : 'Pendente'.hardcoded;
            return PermissionItem(
              title: user.name,
              subtitle: '${user.email} • $roleOrGroup ($statusLabel)'.hardcoded,
              onTap: user.isActive
                  ? () => context
                        .read<UsersCubit>()
                        .navigateToEditUserPermissions(user)
                  : null,
              leading: SizedBox(
                height: 120,
                child: user.avatarUrl?.isNotEmpty ?? false
                    ? BaseImageWidget(
                        width: 120,
                        height: 120,
                        source: BaseImageSource.network(user.avatarUrl),
                        enableFullScreenOnTap: true,
                      )
                    : const PlatformIcon(
                        materialIcon: Icons.person,
                        cupertinoIcon: CupertinoIcons.person,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
