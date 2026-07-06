import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/data_sources/maintenance_plans_local_data_source.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/data_sources/maintenance_plans_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_response_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';

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

  @override
  FutureList<MaintenancePlanEntity> getMaintenancePlans(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMapList<
        MaintenancePlanResponseModel,
        MaintenancePlanEntity
      >(localCallback: () => _localDataSource.getPlans(companyId));

  @override
  FutureData<MaintenancePlanEntity> getMaintenancePlanById(String id) =>
      RepositoryHandler.fetchFromLocalAndMap<
        MaintenancePlanResponseModel,
        MaintenancePlanEntity
      >(localCallback: () => _localDataSource.getPlanById(id));

  @override
  FutureBool createMaintenancePlan(MaintenancePlanEntity plan) =>
      _localDataSource.savePlan(MaintenancePlanResponseModel.fromEntity(plan));

  @override
  FutureBool updateMaintenancePlan(MaintenancePlanEntity plan) =>
      _localDataSource.savePlan(MaintenancePlanResponseModel.fromEntity(plan));

  @override
  FutureBool deleteMaintenancePlan(String id) =>
      _localDataSource.deletePlan(id);
}
