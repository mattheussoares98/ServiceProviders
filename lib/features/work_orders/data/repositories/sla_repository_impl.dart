import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/sla_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/sla_policy_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/sla_repository.dart';

@LazySingleton(as: SlaRepository)
final class SlaRepositoryImpl implements SlaRepository {
  const SlaRepositoryImpl({
    required InternetClient internet,
    required SlaRemoteDataSource remoteDataSource,
    required SlaLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final SlaRemoteDataSource _remoteDataSource;
  final SlaLocalDataSource _localDataSource;

  @override
  FutureList<SlaPolicyEntity> getSlaPolicies(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        SlaPolicyModel,
        SlaPolicyEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getSlaPolicies(companyId),
        remoteCallback: () => _remoteDataSource.getSlaPolicies(companyId),
        onRemoteSuccess: (list) async {
          await Future.wait(list.map(_localDataSource.saveSlaPolicy).toList());
          return const SuccessState(data: true);
        },
      );

  @override
  FutureData<SlaPolicyEntity> getSlaPolicyById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        SlaPolicyModel,
        SlaPolicyEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getSlaPolicyById(id),
        remoteCallback: () => _remoteDataSource.getSlaPolicyById(id),
        onRemoteSuccess: _localDataSource.saveSlaPolicy,
      );
}
