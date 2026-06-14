import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/configurations/data/data_sources/configurations_local_data_source.dart';
import 'package:clean_architecture/features/configurations/data/data_sources/configurations_remote_data_source.dart';
import 'package:clean_architecture/features/configurations/domain/entities/configurations_entity.dart';
import 'package:clean_architecture/features/configurations/domain/repositories/configurations_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ConfigurationsRepository)
final class ConfigurationsRepositoryImpl implements ConfigurationsRepository {
  ConfigurationsRepositoryImpl({
    required InternetClient internet,
    required ConfigurationsRemoteDataSource remoteDataSource,
    required ConfigurationsLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final ConfigurationsRemoteDataSource _remoteDataSource;
  final ConfigurationsLocalDataSource _localDataSource;

  @override
  FutureData<ConfigurationsEntity> getConfigurations() =>
      _localDataSource.getConfigurations();

  @override
  FutureBool savePushNotifications(bool enabled) =>
      _localDataSource.savePushNotifications(enabled);
}
