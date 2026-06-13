import 'package:clean_architecture/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:clean_architecture/features/auth/domain/use_cases/watch_session_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class SessionCubitUseCases {
  const SessionCubitUseCases({
    required this.getSessionUser,
    required this.watchSession,
  });

  final GetSessionUserUseCase getSessionUser;
  final WatchSessionUseCase watchSession;
}
