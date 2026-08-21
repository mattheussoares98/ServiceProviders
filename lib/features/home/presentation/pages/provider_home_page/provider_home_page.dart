import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/provider_home/provider_home_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';

/// Shell for provider mode. Provides the cubits the nested work order pages
/// read from context, so `WorkOrderDetailsPage` and `CreateUpdateWorkOrderPage`
/// are reused unchanged from internal mode.
@RoutePage()
class ProviderHomePage extends HookWidget {
  const ProviderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final heroController = useMemoized(HeroController.new);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProviderHomeCubit>(
          create: (context) => GetIt.I<ProviderHomeCubit>(),
        ),
        BlocProvider<ModeSwitcherCubit>(
          lazy: false,
          create: (context) =>
              GetIt.I<ModeSwitcherCubit>()..checkEligibilityAndLoadMode(),
        ),
        BlocProvider<SessionCubit>(
          create: (context) => GetIt.I<SessionCubit>(),
        ),
        BlocProvider<WorkOrdersCubit>(
          create: (context) =>
              GetIt.I<WorkOrdersCubit>()..loadProviderWorkOrders(),
        ),
        BlocProvider<PauseWorkflowCubit>(
          create: (context) =>
              GetIt.I<PauseWorkflowCubit>()..loadPauseReasons(),
        ),
        // SLA policies, pause reasons and sectors already carry provider RLS
        // branches, so these load normally in provider mode.
        BlocProvider<SlaPoliciesCubit>(
          create: (context) => GetIt.I<SlaPoliciesCubit>()..loadSlaPolicies(),
        ),
        // Constructed but not loaded here: locations and assets cannot be fetched
        // by company in provider mode. `ProviderLookupsLoader` feeds them the ids
        // the loaded work orders reference, which is the scope RLS grants.
        // Users stays empty — `user_profiles` is still company-scoped, and the
        // widgets reading it render without a label.
        BlocProvider<LocationsCubit>(
          create: (context) => GetIt.I<LocationsCubit>(),
        ),
        BlocProvider<AssetsCubit>(create: (context) => GetIt.I<AssetsCubit>()),
        BlocProvider<UsersCubit>(create: (context) => GetIt.I<UsersCubit>()),
        BlocProvider<ServiceProvidersCubit>(
          create: (context) => GetIt.I<ServiceProvidersCubit>(),
        ),
      ],
      child: HeroControllerScope(
        controller: heroController,
        child: const AutoRouter(),
      ),
    );
  }
}
