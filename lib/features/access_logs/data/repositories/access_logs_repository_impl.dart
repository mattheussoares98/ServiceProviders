import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/data_sources/access_logs_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/requests/create_access_log_request_model.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/models/responses/access_log_model.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/access_log_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/create_access_log_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/entities/get_access_logs_request_entity.dart';
import 'package:o_jogo_da_obra/features/access_logs/domain/repositories/access_logs_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: AccessLogsRepository)
final class AccessLogsRepositoryImpl implements AccessLogsRepository {
  const AccessLogsRepositoryImpl({
    required InternetClient internet,
    required AccessLogsRemoteDataSource remoteDataSource,
    required SyncRepository syncRepository,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _syncRepository = syncRepository;

  final InternetClient _internet;
  final AccessLogsRemoteDataSource _remoteDataSource;
  final SyncRepository _syncRepository;

  @override
  FutureList<AccessLogEntity> getAccessLogs(
    GetAccessLogsRequestEntity request,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        AccessLogModel,
        AccessLogEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getAccessLogs(request),
      );

  @override
  FutureVoid createAccessLog(CreateAccessLogRequestEntity request) =>
      RepositoryHandler.fetchWithFallback<void>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final requestModel = CreateAccessLogRequestModel.fromEntity(request);
          final entityId = const Uuid().v4();
          await _syncRepository.enqueue(
            SyncQueueItemEntity(
              id: const Uuid().v4(),
              companyId: request.companyId,
              userProfileId: request.userId,
              entityType: SyncEntityType.accessLog,
              entityId: entityId,
              operation: SyncOperationType.create,
              payload: jsonEncode(requestModel.toJson()),
              createdAt: DateTime.now().toUtc(),
            ),
          );
          return SuccessState.nil;
        },
        remoteCallback: () async {
          final requestModel = CreateAccessLogRequestModel.fromEntity(request);
          final result = await _remoteDataSource.createAccessLog(requestModel);
          if (result is SuccessState) {
            return SuccessState.nil;
          }
          final entityId = const Uuid().v4();
          await _syncRepository.enqueue(
            SyncQueueItemEntity(
              id: const Uuid().v4(),
              companyId: request.companyId,
              userProfileId: request.userId,
              entityType: SyncEntityType.accessLog,
              entityId: entityId,
              operation: SyncOperationType.create,
              payload: jsonEncode(requestModel.toJson()),
              createdAt: DateTime.now().toUtc(),
            ),
          );
          return SuccessState.nil;
        },
      );
}
