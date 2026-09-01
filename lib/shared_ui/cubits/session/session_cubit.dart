import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit_use_cases.dart';

part 'session_state.dart';

@injectable
class SessionCubit extends BaseCubit<SessionState> {
  SessionCubit({required SessionCubitUseCases useCases})
    : _useCases = useCases,
      super(
        SessionState(
          user: useCases.getSessionUser.call(),
          isLoggedIn: useCases.getSessionUser.call().id.isNotEmpty,
        ),
      ) {
    _init();
  }

  final SessionCubitUseCases _useCases;
  StreamSubscription<UserDataEntity>? _subscription;

  void _init() {
    _subscription = _useCases.watchSession.call().listen((userData) {
      emit(
        SessionState(
          user: userData.user,
          isLoggedIn: userData.accessToken.isNotEmpty,
          status: DataStatus.loaded,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
