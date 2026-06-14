import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/configurations/presentation/cubits/configurations/configurations_cubit.dart';
import 'package:clean_architecture/features/configurations/presentation/pages/configurations/widgets/danger_zone_card.dart';
import 'package:clean_architecture/features/configurations/presentation/pages/configurations/widgets/notifications_toggle.dart';
import 'package:clean_architecture/features/configurations/presentation/pages/configurations/widgets/theme_selector_card.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class ConfigurationsPage extends StatelessWidget {
  const ConfigurationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfigurationsCubit>(
      create: (context) => GetIt.I<ConfigurationsCubit>()..loadConfigurations(),
      child: const _ConfigurationsPageBody(),
    );
  }
}

class _ConfigurationsPageBody extends StatelessWidget {
  const _ConfigurationsPageBody();

  @override
  Widget build(BuildContext context) {
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
