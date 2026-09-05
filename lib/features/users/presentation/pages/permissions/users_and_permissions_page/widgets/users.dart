import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/users_and_permissions_page/widgets/permission_item.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_image_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_state_view.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_list_flow.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_rich_text.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class Users extends StatelessWidget {
  const Users({super.key});
  @override
  Widget build(BuildContext context) {
    final sessionUser = context.select<SessionCubit, UserProfileEntity>(
      (cubit) => cubit.state.user,
    );
    final isCurrentUserAdmin = sessionUser.isAdmin;

    return BaseStateView<UsersCubit, UsersState, List<UserProfileEntity>>(
      dataSelector: (state) => state.users,
      onRetry: () => context.read<UsersCubit>().loadAll(),
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

            final lastAccessText = isCurrentUserAdmin
                ? user.lastAccessAt != null
                      ? '\nÚltimo acesso: ${user.lastAccessAt!.toLocal().formatDate(DateFormatType.ddMMyyyyHHmm)}'
                            .hardcoded
                      : '\nÚltimo acesso: Nunca'.hardcoded
                : null;

            return PermissionItem(
              title: user.name,
              subtitle: BaseRichText(
                texts: [
                  BaseText.title(user.email),
                  BaseText(' • $roleOrGroup'),
                  if (lastAccessText != null) BaseText.caption(lastAccessText),
                  if (!user.isActive)
                    BaseText(' Pendente'.hardcoded, color: Colors.orange),
                ],
              ),
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
