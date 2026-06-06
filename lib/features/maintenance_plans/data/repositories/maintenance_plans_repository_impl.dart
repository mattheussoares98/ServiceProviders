import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_remote_data_source.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: MaintenancePlansRepository)
final class MaintenancePlansRepositoryImpl implements MaintenancePlansRepository {
  MaintenancePlansRepositoryImpl({
    required InternetClient internet,
    required MaintenancePlansRemoteDataSource remoteDataSource,
    required MaintenancePlansLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final MaintenancePlansRemoteDataSource _remoteDataSource;
  final MaintenancePlansLocalDataSource _localDataSource;
}
