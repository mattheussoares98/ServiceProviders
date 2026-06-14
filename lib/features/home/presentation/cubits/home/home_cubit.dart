import 'dart:async';

import 'package:clean_architecture/features/home/presentation/cubits/home/home_cubit_use_cases.dart';
import 'package:clean_architecture/routing/routes.gr.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:injectable/injectable.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState> {
  HomeCubit({required HomeCubitUseCases useCases})
    : _useCases = useCases,
      super(const HomeState.empty());

  final HomeCubitUseCases _useCases;

  Future<void> logout() async {
    unawaited(_useCases.logOut.call());
    await replaceAllRoute(const LoginRoute());
  }

  Future<void> navigateToCompany() async {
    await pushRoute(const CompanyRoute());
  }

  Future<void> navigateToConfigurations() async {
    await pushRoute(const ConfigurationsRoute());
  }
}

