import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';

@LazySingleton()
class SplashCubitUseCases {
  const SplashCubitUseCases({
    required this.sessionRepository,
    required this.getSelectedMode,
    required this.getSessionUser,
  });

  final SessionRepository sessionRepository;
  final GetSelectedModeUseCase getSelectedMode;
  final GetSessionUserUseCase getSessionUser;
}
