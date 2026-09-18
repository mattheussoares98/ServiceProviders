import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/account_security_card.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/danger_zone_card.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/notifications_toggle.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/theme_selector_card.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/responsive/responsive_scrollable_widget.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class ConfigurationsPage extends StatelessWidget {
  const ConfigurationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      isScrollable: false,
      appBar: BaseAppBar(title: 'Configurações'),
      body: ResponsiveScrollableWidget(
        centralize: true,
        child: Column(
          children: [
            ThemeSelectorCard(),
            gapH16,
            NotificationsToggle(),
            gapH16,
            AccountSecurityCard(),
            gapH16,
            DangerZoneCard(),
            gapH24,
          ],
        ),
      ),
    );
  }
}
