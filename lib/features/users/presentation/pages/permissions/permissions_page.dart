import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/widgets/groups.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/widgets/users.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_bottom_navigation_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/platform_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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

    return BaseScaffold(
      isScrollable: false,
      usePadding: false,
      onRefresh: () => context.read<UsersCubit>().loadAll(emitLoading: false),
      appBar: BaseAppBar(title: 'Permissões'.hardcoded),
      body: PageView(
        controller: pageController,
        onPageChanged: onChangePage,
        children: const [Groups(), Users()],
      ),
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
  }
}
