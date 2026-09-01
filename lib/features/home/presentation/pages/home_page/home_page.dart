import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/auth/presentation/cubits/mode_switcher/mode_switcher_cubit.dart';
import 'package:o_jogo_da_obra/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:o_jogo_da_obra/features/home/presentation/pages/home_page/widgets/error_page.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/pause_workflow/pause_workflow_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';

@RoutePage()
class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(HeroController.new);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(create: (context) => GetIt.I<HomeCubit>()),
        BlocProvider<ModeSwitcherCubit>(
          lazy: false,
          create: (context) =>
              GetIt.I<ModeSwitcherCubit>()..checkEligibilityAndLoadMode(),
        ),
        BlocProvider<SessionCubit>(
          create: (context) => GetIt.I<SessionCubit>(),
        ),
        BlocProvider<CompanyCubit>(
          create: (context) => GetIt.I<CompanyCubit>()..loadCompany(),
        ),
        BlocProvider<LocationsCubit>(
          create: (context) =>
              GetIt.I<LocationsCubit>()..loadLocationsAndAreas(),
        ),
        BlocProvider<AssetsCubit>(
          create: (context) => GetIt.I<AssetsCubit>()..loadAssets(),
        ),
        BlocProvider<WorkOrdersCubit>(
          create: (context) => GetIt.I<WorkOrdersCubit>()
            ..loadWorkOrdersAndChangeRequests()
            ..syncWorkOrders(),
        ),
        BlocProvider<UsersCubit>(
          create: (context) => GetIt.I<UsersCubit>()..loadAll(),
        ),
        BlocProvider<CategoriesCubit>(
          create: (context) => GetIt.I<CategoriesCubit>()..loadCategories(),
        ),
        BlocProvider<SectorsCubit>(
          create: (context) => GetIt.I<SectorsCubit>()..loadSectors(),
        ),
        BlocProvider<SlaPoliciesCubit>(
          create: (context) => GetIt.I<SlaPoliciesCubit>()..loadSlaPolicies(),
        ),
        BlocProvider(
          create: (context) =>
              GetIt.I<ServiceProvidersCubit>()..loadCompaniesAndProfiles(),
        ),
        BlocProvider<PauseWorkflowCubit>(
          create: (context) {
            return GetIt.I<PauseWorkflowCubit>()..loadPauseReasons();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<CompanyCubit, CompanyState>(
            listenWhen: (previous, current) =>
                previous.selectedCompanyId != null &&
                current.selectedCompanyId != null &&
                previous.selectedCompanyId != current.selectedCompanyId,
            listener: (context, state) {
              context.read<WorkOrdersCubit>().loadWorkOrdersAndChangeRequests();
              context.read<AssetsCubit>().loadAssets();
              context.read<LocationsCubit>().loadLocationsAndAreas();
              context.read<UsersCubit>().loadAll();
              context.read<CategoriesCubit>().loadCategories();
              context.read<SectorsCubit>().loadSectors();
              context.read<SlaPoliciesCubit>().loadSlaPolicies();
              context.read<ServiceProvidersCubit>().loadCompaniesAndProfiles();
              context.read<PauseWorkflowCubit>().loadPauseReasons();
            },
            child: BaseScaffold(
              usePadding: false,
              isScrollable: false,
              body: BlocBuilder<UsersCubit, UsersState>(
                builder: (context, state) {
                  final sectionStatus = state.sections[UsersSections.loadAll];
                  final isLoading = sectionStatus != null
                      ? sectionStatus == SectionStatus.running
                      : state.status == DataStatus.loading;
                  final hasError = sectionStatus != null
                      ? sectionStatus == SectionStatus.error
                      : state.status == DataStatus.loadingError;

                  if (state.users.isEmpty && state.permissionGroups.isEmpty) {
                    if (isLoading) {
                      return const LoadingCircle();
                    }
                    if (hasError) {
                      return const ErrorPage();
                    }
                  }

                  return HeroControllerScope(
                    controller: controller,
                    child: const AutoRouter(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
