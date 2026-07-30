import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';

@LazySingleton()
class ModeSwitcherCubitUseCases {
  const ModeSwitcherCubitUseCases({
    required this.getSessionUser,
    required this.getServiceProviderProfilesByAuthUser,
    required this.saveSelectedMode,
    required this.getSelectedMode,
  });

  final GetSessionUserUseCase getSessionUser;
  final GetServiceProviderProfilesByAuthUserUseCase
  getServiceProviderProfilesByAuthUser;
  final SaveSelectedModeUseCase saveSelectedMode;
  final GetSelectedModeUseCase getSelectedMode;
}
