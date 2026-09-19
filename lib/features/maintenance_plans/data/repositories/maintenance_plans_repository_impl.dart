import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/data_sources/maintenance_plans_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/repositories/maintenance_plans_repository.dart';

@LazySingleton(as: MaintenancePlansRepository)
final class MaintenancePlansRepositoryImpl
    implements MaintenancePlansRepository {
  MaintenancePlansRepositoryImpl({
    required InternetClient internet,
    required MaintenancePlansRemoteDataSource remoteDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource;

  final InternetClient _internet;
  final MaintenancePlansRemoteDataSource _remoteDataSource;

  @override
  FutureList<MaintenancePlanEntity> getMaintenancePlans(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        MaintenancePlanModel,
        MaintenancePlanEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getPlans(companyId),
      );

  @override
  FutureData<MaintenancePlanEntity> getMaintenancePlanById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        MaintenancePlanModel,
        MaintenancePlanEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getPlanById(id),
      );

  @override
  FutureBool createMaintenancePlan(MaintenancePlanEntity plan) async {
    if (!_internet.isConnected) {
      return FailureState(
        message:
            'A criação de planos de manutenção requer conexão com a internet',
      );
    }
    final result = await _remoteDataSource.createPlan(
      MaintenancePlanModel.fromEntity(plan),
    );
    if (result is SuccessState<MaintenancePlanModel> && result.data != null) {
      return const SuccessState(data: true);
    }
    return FailureState(message: result.message);
  }

  @override
  FutureBool updateMaintenancePlan(MaintenancePlanEntity plan) async {
    if (!_internet.isConnected) {
      return FailureState(
        message:
            'A edição de planos de manutenção requer conexão com a internet',
      );
    }
    final result = await _remoteDataSource.updatePlan(
      MaintenancePlanModel.fromEntity(plan),
    );
    if (result is SuccessState<MaintenancePlanModel> && result.data != null) {
      return const SuccessState(data: true);
    }
    return FailureState(message: result.message);
  }

  @override
  FutureBool deleteMaintenancePlan(String id) async {
    if (!_internet.isConnected) {
      return FailureState(
        message:
            'A exclusão de planos de manutenção requer conexão com a internet',
      );
    }
    final result = await _remoteDataSource.deletePlan(id);
    if (result is SuccessState) {
      return const SuccessState(data: true);
    }
    return FailureState(message: result.message);
  }

  @override
  FutureData<String> generateWorkOrder(String planId) async {
    if (!_internet.isConnected) {
      return FailureState(
        message: 'A geração de ordens de serviço requer conexão com a internet',
      );
    }
    return await _remoteDataSource.generateWorkOrder(planId);
  }
}
