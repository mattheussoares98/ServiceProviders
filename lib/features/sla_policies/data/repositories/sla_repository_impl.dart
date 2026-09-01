import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/repositories/sla_repository.dart';

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

  @override
  FutureBool createSlaPolicy(SlaPolicyEntity policy) =>
      RepositoryHandler.fetchWithFallback(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.createSlaPolicy(
          SlaPolicyModel.fromEntity(policy),
        ),
        localCallback: () =>
            _localDataSource.saveSlaPolicy(SlaPolicyModel.fromEntity(policy)),
        onRemoteSuccess: (_) =>
            _localDataSource.saveSlaPolicy(SlaPolicyModel.fromEntity(policy)),
      );

  @override
  FutureBool updateSlaPolicy(SlaPolicyEntity policy) =>
      RepositoryHandler.fetchWithFallback(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.updateSlaPolicy(
          SlaPolicyModel.fromEntity(policy),
        ),
        localCallback: () =>
            _localDataSource.saveSlaPolicy(SlaPolicyModel.fromEntity(policy)),
        onRemoteSuccess: (_) =>
            _localDataSource.saveSlaPolicy(SlaPolicyModel.fromEntity(policy)),
      );

  @override
  FutureBool deleteSlaPolicy(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.deleteSlaPolicy(id),
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteSlaPolicy(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deleteSlaPolicy(id);
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

  @override
  Stream<RealtimeEvent<SlaPolicyEntity>> watchSlaPoliciesRealtime({
    String? companyId,
  }) {
    return _remoteDataSource
        .watchSlaPoliciesRealtime(companyId: companyId)
        .asyncMap((event) async {
          if (event.entity != null &&
              (event.eventType == RealtimeEventType.insert ||
                  event.eventType == RealtimeEventType.update)) {
            if (event.entity!.deletedAt != null) {
              await _localDataSource.deleteSlaPolicy(event.id);
            } else {
              await _localDataSource.saveSlaPolicy(event.entity!);
            }
          } else if (event.eventType == RealtimeEventType.delete &&
              event.id.isNotEmpty) {
            await _localDataSource.deleteSlaPolicy(event.id);
          }

          return RealtimeEvent<SlaPolicyEntity>(
            eventType: event.eventType,
            id: event.id,
            companyId: event.companyId,
            entity: event.entity,
          );
        });
  }
}
