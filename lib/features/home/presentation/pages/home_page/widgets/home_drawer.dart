import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/categories_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/checklists_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/company_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/logout_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/maintenance_plans_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/permissions_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/sectors_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/service_providers_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/settings_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/sla_policies_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/user_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/home_drawer_header.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/widgets/mode_switcher_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.theme.colorScheme.surface,
      width: ScreenUtil.I.widthPart(85, max: 400),
      child: const Column(
        children: [
          HomeDrawerHeader(),
          UserDrawerItem(),

          ModeSwitcherDrawerItem(),
          CategoriesDrawerItem(),
          ChecklistsDrawerItem(),
          SettingsDrawerItem(),
          CompanyDrawerItem(),
          MaintenancePlansDrawerItem(),
          ServiceProvidersDrawerItem(),
          SlaPoliciesDrawerItem(),

          // HomeDrawerItem(),
          // ProfileDrawerItem(),
          SectorsDrawerItem(),
          PermissionsDrawerItem(),
          Spacer(),
          Divider(height: 1),
          LogoutDrawerItem(),
          gapH16,
        ],
      ),
    );
  }
}
