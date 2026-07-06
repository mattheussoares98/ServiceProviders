import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_local_data_source.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/repositories/configurations_repository.dart';

@LazySingleton(as: ConfigurationsRepository)
final class ConfigurationsRepositoryImpl implements ConfigurationsRepository {
  ConfigurationsRepositoryImpl({
    required InternetClient internet,
    required ConfigurationsRemoteDataSource remoteDataSource,
    required ConfigurationsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final ConfigurationsRemoteDataSource _remoteDataSource;
  final ConfigurationsLocalDataSource _localDataSource;

  @override
  FutureData<ConfigurationsEntity> getConfigurations() =>
      _localDataSource.getConfigurations();
  //TODO load remotely too

  @override
  FutureBool savePushNotifications(bool enabled) =>
      _localDataSource.savePushNotifications(enabled);
  //TODO load remotely too
}
