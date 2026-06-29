import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/presentation/cubits/invite_user/invite_user_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/invite_user/invite_user_page.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/permissions_page/widgets/groups.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/permissions_page/widgets/users.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_bottom_navigation_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:clean_architecture/shared_ui/ui/base/show_modal_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class PermissionsPage extends HookWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    final pageController = useState(PageController()).value;
    void onChangePage(int index) {
      selectedIndex.value = index;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return BlocProvider<InviteUserCubit>(
      create: (context) => GetIt.I<InviteUserCubit>(),
      child: Builder(
        builder: (context) {
          return BaseScaffold(
            isScrollable: false,
            usePadding: false,
            onRefresh: () =>
                context.read<UsersCubit>().loadAll(emitLoading: false),
            appBar: BaseAppBar(title: 'Permissões'.hardcoded),
            body: PageView(
              controller: pageController,
              onPageChanged: onChangePage,
              children: const [Groups(), Users()],
            ),
            floatingActionButton: selectedIndex.value == 1
                ? FloatingActionButton(
                    onPressed: () => showModalPage<void>(
                      BlocProvider.value(
                        value: context.read<InviteUserCubit>(),
                        child: const InviteUserPage(),
                      ),
                      context,
                    ),
                    child: const Icon(Icons.person_add),
                  )
                : null,
            bottomNavigationBar: BaseBottomNavigationBar(
              currentIndex: selectedIndex.value,
              onTap: onChangePage,
              items: [
                BaseBottomNavigationBarItem(
                  label: 'Grupos'.hardcoded,
                  platformIcon: PlatformIcon(
                    materialIcon: Icons.group,
                    cupertinoIcon: selectedIndex.value == 0
                        ? CupertinoIcons.group_solid
                        : CupertinoIcons.group,
                  ),
                ),
                BaseBottomNavigationBarItem(
                  label: 'Usuários'.hardcoded,
                  platformIcon: PlatformIcon(
                    materialIcon: Icons.person,
                    cupertinoIcon: selectedIndex.value == 1
                        ? CupertinoIcons.person_solid
                        : CupertinoIcons.person,
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
