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

@RoutePage()
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final items = [
      BaseBottomNavigationBarItem(
        label: 'Grupos'.hardcoded,
        platformIcon: const PlatformIcon(
          materialIcon: Icons.group,
          cupertinoIcon: CupertinoIcons.group,
        ),
      ),
      BaseBottomNavigationBarItem(
        label: 'Usuários'.hardcoded,
        platformIcon: const PlatformIcon(
          materialIcon: Icons.person,
          cupertinoIcon: CupertinoIcons.person,
        ),
      ),
    ];
    return DefaultTabController(
      length: 2,
      child: BaseScaffold(
        observeScreenChanges: true,
        isScrollable: false,
        onRefresh: () => context.read<UsersCubit>().loadAll(emitLoading: false),
        appBar: BaseAppBar(title: 'Permissões'.hardcoded),
        body: const TabBarView(children: [Groups(), Users()]),
        bottomNavigationBar: BaseBottomNavigationBar(
          items: items,
          currentIndex: _selectedIndex,
          onTap: (value) => setState(() {
            _selectedIndex = value;
          }),
        ),
      ),
    );
  }
}
