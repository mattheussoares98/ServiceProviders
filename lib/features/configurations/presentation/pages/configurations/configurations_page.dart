import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/danger_zone_card.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/notifications_toggle.dart';
import 'package:o_jogo_da_obra/features/configurations/presentation/pages/configurations/widgets/theme_selector_card.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

@RoutePage()
class ConfigurationsPage extends HookWidget {
  const ConfigurationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lifecycleState = useAppLifecycleState();

    useEffect(() {
      context.read<ConfigurationsCubit>().loadConfigurations();
      return null;
    }, []);

    useEffect(() {
      if (lifecycleState == AppLifecycleState.resumed) {
        context.read<ConfigurationsCubit>().loadConfigurations();
      }
      return null;
    }, [lifecycleState]);

    return const BaseScaffold(
      appBar: BaseAppBar(title: 'Configurações'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ThemeSelectorCard(),
            gapH16,
            NotificationsToggle(),
            gapH16,
            DangerZoneCard(),
            gapH24,
          ],
        ),
      ),
    );
  }
}
