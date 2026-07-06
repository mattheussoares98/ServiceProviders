import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/home_drawer.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

@RoutePage()
class HomeTabsPage extends StatelessWidget {
  const HomeTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        DashboardRoute(),
        WorkOrdersRoute(),
        AssetsRoute(),
        LocationsRoute(),
      ],
      drawer: const HomeDrawer(),
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: [
            NavigationDestination(
              icon: const PlatformIcon(
                materialIcon: Icons.dashboard_outlined,
                cupertinoIcon: CupertinoIcons.square_grid_2x2,
              ),
              selectedIcon: const PlatformIcon(
                materialIcon: Icons.dashboard,
                cupertinoIcon: CupertinoIcons.square_grid_2x2_fill,
              ),
              label: 'Início'.hardcoded,
            ),
            NavigationDestination(
              icon: const PlatformIcon(
                materialIcon: Icons.assignment_outlined,
                cupertinoIcon: CupertinoIcons.doc_text,
              ),
              selectedIcon: const PlatformIcon(
                materialIcon: Icons.assignment,
                cupertinoIcon: CupertinoIcons.doc_text_fill,
              ),
              label: 'Ordens'.hardcoded,
            ),
            NavigationDestination(
              icon: const PlatformIcon(
                materialIcon: Icons.build_outlined,
                cupertinoIcon: CupertinoIcons.wrench,
              ),
              selectedIcon: const PlatformIcon(
                materialIcon: Icons.build,
                cupertinoIcon: CupertinoIcons.wrench_fill,
              ),
              label: 'Equipamentos'.hardcoded,
            ),
            NavigationDestination(
              icon: const PlatformIcon(
                materialIcon: Icons.location_on_outlined,
                cupertinoIcon: CupertinoIcons.location,
              ),
              selectedIcon: const PlatformIcon(
                materialIcon: Icons.location_on,
                cupertinoIcon: CupertinoIcons.location_fill,
              ),
              label: 'Locais'.hardcoded,
            ),
          ],
        );
      },
    );
  }
}
