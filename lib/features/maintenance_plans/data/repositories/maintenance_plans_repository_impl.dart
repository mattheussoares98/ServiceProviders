import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:clean_architecture/features/maintenance_plans/data/data_sources/maintenance_plans_remote_data_source.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: MaintenancePlansRepository)
final class MaintenancePlansRepositoryImpl
    implements MaintenancePlansRepository {
  MaintenancePlansRepositoryImpl({
    required InternetClient internet,
    required MaintenancePlansRemoteDataSource remoteDataSource,
    required MaintenancePlansLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final MaintenancePlansRemoteDataSource _remoteDataSource;
  final MaintenancePlansLocalDataSource _localDataSource;

  // TODO: Wire to local/remote data sources with RepositoryHandler
  @override
  FutureList<MaintenancePlanEntity> getMaintenancePlans(String companyId) =>
      throw UnimplementedError();

  @override
  FutureData<MaintenancePlanEntity> getMaintenancePlanById(String id) =>
      throw UnimplementedError();

  @override
  FutureBool createMaintenancePlan(MaintenancePlanEntity plan) =>
      throw UnimplementedError();

  @override
  FutureBool updateMaintenancePlan(MaintenancePlanEntity plan) =>
      throw UnimplementedError();

  @override
  FutureBool deleteMaintenancePlan(String id) => throw UnimplementedError();
}
