import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/drawer/drawer_items/logout_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class ServiceProviderHomeDrawer extends StatelessWidget {
  const ServiceProviderHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.theme.colorScheme.surface,
      width: ScreenUtil.I.widthPart(85, max: 400),
      child: const Column(
        children: [Spacer(), Divider(height: 1), LogoutDrawerItem(), gapH16],
      ),
    );
  }
}
