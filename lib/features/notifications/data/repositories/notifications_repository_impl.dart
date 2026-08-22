import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/notifications/data/data_sources/notifications_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/repositories/notifications_repository.dart';

@LazySingleton(as: NotificationsRepository)
final class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required InternetClient internet,
    required NotificationsRemoteDataSource remoteDataSource,
    required SessionRepository sessionRepository,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _sessionRepository = sessionRepository;

  final InternetClient _internet;
  final NotificationsRemoteDataSource _remoteDataSource;
  final SessionRepository _sessionRepository;

  String? _resolveUserId() {
    final userId = _sessionRepository.userData.user.id;
    if (userId.isNotEmpty) return userId;
    return _sessionRepository.currentAuthUser?.id;
  }

  @override
  FutureBool registerDeviceToken({
    required String deviceToken,
    required String platform,
  }) => RepositoryHandler.fetchWithFallback<bool>(
    isInternetConnected: _internet.isConnected,
    remoteCallback: () {
      final userId = _resolveUserId();
      if (userId == null || userId.isEmpty) {
        return Future.value(
          FailureState(message: 'Usuário não autenticado'.hardcoded),
        );
      }
      return _remoteDataSource.registerDeviceToken(
        userId: userId,
        deviceToken: deviceToken,
        platform: platform,
      );
    },
  );

  @override
  FutureBool deleteDeviceToken(String deviceToken) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () {
          final userId = _resolveUserId();
          if (userId == null || userId.isEmpty) {
            return Future.value(
              FailureState(message: 'Usuário não autenticado'.hardcoded),
            );
          }
          return _remoteDataSource.deleteDeviceToken(
            userId: userId,
            deviceToken: deviceToken,
          );
        },
      );
}
