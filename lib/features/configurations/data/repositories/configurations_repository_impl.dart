import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/configurations/data/models/responses/configurations_response_model.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/repositories/configurations_repository.dart';

@LazySingleton(as: ConfigurationsRepository)
final class ConfigurationsRepositoryImpl implements ConfigurationsRepository {
  ConfigurationsRepositoryImpl({
    required InternetClient internet,
    required ConfigurationsRemoteDataSource remoteDataSource,
    required ConfigurationsLocalDataSource localDataSource,
    required SessionRepository sessionRepository,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _sessionRepository = sessionRepository;

  final InternetClient _internet;
  final ConfigurationsRemoteDataSource _remoteDataSource;
  final ConfigurationsLocalDataSource _localDataSource;
  final SessionRepository _sessionRepository;

  @override
  FutureData<ConfigurationsEntity> getConfigurations() =>
      RepositoryHandler.fetchWithFallbackAndMap<
        ConfigurationsResponseModel,
        ConfigurationsEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () {
          final userId = _sessionRepository.userData.user.id;
          return _remoteDataSource.getConfigurations(userId);
        },
        localCallback: _localDataSource.getConfigurations,
        onRemoteSuccess: _localDataSource.saveConfigurations,
      );

  @override
  FutureBool savePushNotifications(bool enabled) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.savePushNotifications(enabled),
        remoteCallback: () async {
          final userId = _sessionRepository.userData.user.id;

          // Get local configurations to obtain the currently selected themeMode
          final localConfigResult = await _localDataSource.getConfigurations();
          final themeMode = localConfigResult.data?.themeMode ?? 'system';

          final result = await _remoteDataSource.saveConfigurations(
            userId: userId,
            pushNotificationsEnabled: enabled,
            themeMode: themeMode,
          );

          if (result is SuccessState<void>) {
            await _localDataSource.savePushNotifications(enabled);
            return const SuccessState(data: true);
          }

          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );
}
