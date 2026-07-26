import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';

@LazySingleton()
class ModeSwitcherCubitUseCases {
  const ModeSwitcherCubitUseCases({
    required this.getSessionUser,
    required this.getServiceProviderProfilesByAuthUser,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetServiceProviderProfilesByAuthUserUseCase getServiceProviderProfilesByAuthUser;
}
