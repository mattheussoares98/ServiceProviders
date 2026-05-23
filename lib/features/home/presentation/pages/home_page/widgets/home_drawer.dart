import 'package:clean_architecture/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/home_drawer_item.dart';
import 'package:clean_architecture/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/logout_drawer_item.dart';
import 'package:clean_architecture/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/profile_drawer_item.dart';
import 'package:clean_architecture/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/settings_drawer_item.dart';
import 'package:clean_architecture/features/home/presentation/pages/home_page/widgets/drawer/home_drawer_header.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';

/// A premium, responsive navigation Drawer for the HomePage dashboard.
///
/// It flat-renders separated modular sub-widgets directly inside its primary Column.
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      width: MediaQuery.sizeOf(context).width * 0.85,
      child: const Column(
        children: [
          HomeDrawerHeader(),
          HomeDrawerItem(),
          ProfileDrawerItem(),
          SettingsDrawerItem(),
          Spacer(),
          Divider(height: 1),
          LogoutDrawerItem(),
          gapH16,
        ],
      ),
    );
  }
}
