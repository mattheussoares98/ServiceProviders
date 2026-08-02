import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/home/presentation/cubits/provider_home/provider_home_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

part 'provider_home_state.dart';

@injectable
class ProviderHomeCubit extends BaseCubit<ProviderHomeState> {
  ProviderHomeCubit({required ProviderHomeCubitUseCases useCases})
    : _useCases = useCases,
      super(const ProviderHomeState.empty());

  final ProviderHomeCubitUseCases _useCases;

  Future<void> logout() async {
    await _useCases.logOut.call();
    unawaited(_useCases.clearLocalAttachments.call());
    await replaceAllRoute(const SplashRoute());
  }
}
