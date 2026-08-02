import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/provider_home_page/widgets/provider_logout_drawer_item.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/widgets/mode_switcher_drawer_item.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/screen_util/screen_util.dart';

class ProviderHomeDrawer extends StatelessWidget {
  const ProviderHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.theme.colorScheme.surface,
      width: ScreenUtil.I.widthPart(85, max: 400),
      child: const Column(
        children: [
          ModeSwitcherDrawerItem(),
          Spacer(),
          Divider(height: 1),
          ProviderLogoutDrawerItem(),
          gapH16,
        ],
      ),
    );
  }
}
