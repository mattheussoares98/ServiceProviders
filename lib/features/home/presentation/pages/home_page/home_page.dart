import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:clean_architecture/features/categories/presentation/cubits/categories/categories_cubit.dart';
import 'package:clean_architecture/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit.dart';
import 'package:clean_architecture/features/home/presentation/pages/home_page/widgets/error_page.dart';
import 'package:clean_architecture/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/work_orders/presentation/cubits/work_orders/work_orders_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(HeroController.new);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(create: (context) => GetIt.I<HomeCubit>()),
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
          create: (context) =>
              GetIt.I<WorkOrdersCubit>()..loadWorkOrdersAndChangeRequests(),
        ),
        BlocProvider<CategoriesCubit>(
          create: (context) => GetIt.I<CategoriesCubit>()..loadCategories(),
        ),
      ],
      child: BlocSelector<UsersCubit, UsersState, StateStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          if (status == StateStatus.loadingError) {
            return const ErrorPage();
          }

          if (status == StateStatus.loading || status == StateStatus.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return HeroControllerScope(
            controller: controller,
            child: const AutoRouter(),
          );
        },
      ),
    );
  }
}
