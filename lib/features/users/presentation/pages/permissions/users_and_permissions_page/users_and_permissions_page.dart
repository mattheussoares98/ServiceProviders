import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/invite_user/invite_user_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/invitations/invitations_page.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/invite_user/invite_user_page.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/users_and_permissions_page/widgets/groups.dart';
import 'package:o_jogo_da_obra/features/users/presentation/pages/permissions/users_and_permissions_page/widgets/users.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_bottom_navigation_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/show_modal_page.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

@RoutePage()
class UsersAndPermissionsPage extends HookWidget {
  const UsersAndPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    void onPageChanged(int index) => selectedIndex.value = index;

    return BlocProvider<InviteUserCubit>(
      create: (context) => GetIt.I<InviteUserCubit>(),
      child: Builder(
        builder: (context) {
          final canInviteUsers = context.hasPermission(
            const ActionPermission(
              resource: ResourceType.users,
              action: PermissionAction.create,
            ),
          );
          return BaseScaffold(
            isScrollable: false,
            usePadding: false,
            onRefresh: () =>
                context.read<UsersCubit>().loadAll(emitLoading: false),
            appBar: BaseAppBar(title: 'Permissões'.hardcoded),
            body: [
              const Users(),
              const InvitationsPage(),
              const Groups(),
            ][selectedIndex.value],
            floatingActionButton:
                canInviteUsers &&
                    (selectedIndex.value == 0 || selectedIndex.value == 1)
                ? FloatingActionButton(
                    onPressed: () => showModalPage<void>(
                      BlocProvider.value(
                        value: context.read<InviteUserCubit>(),
                        child: const InviteUserPage(),
                      ),
                      context,
                    ),
                    child: const PlatformIcon(
                      materialIcon: Icons.person_add,
                      cupertinoIcon: CupertinoIcons.person_add,
                    ),
                  )
                : null,
            bottomNavigationBar: BaseBottomNavigationBar(
              currentIndex: selectedIndex.value,
              onTap: onPageChanged,
              items: [
                BaseBottomNavigationBarItem(
                  label: 'Usuários'.hardcoded,
                  platformIcon: PlatformIcon(
                    materialIcon: Icons.person,
                    cupertinoIcon: selectedIndex.value == 0
                        ? CupertinoIcons.person_solid
                        : CupertinoIcons.person,
                  ),
                ),
                BaseBottomNavigationBarItem(
                  label: 'Convites'.hardcoded,
                  platformIcon: PlatformIcon(
                    materialIcon: Icons.mail,
                    cupertinoIcon: selectedIndex.value == 1
                        ? CupertinoIcons.mail_solid
                        : CupertinoIcons.mail,
                  ),
                ),
                BaseBottomNavigationBarItem(
                  label: 'Grupos'.hardcoded,
                  platformIcon: PlatformIcon(
                    materialIcon: Icons.group,
                    cupertinoIcon: selectedIndex.value == 2
                        ? CupertinoIcons.group_solid
                        : CupertinoIcons.group,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
