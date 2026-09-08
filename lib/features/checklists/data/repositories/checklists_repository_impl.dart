import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_answer_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_item_model.dart';
import 'package:o_jogo_da_obra/features/checklists/data/models/responses/checklist_template_model.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_answer_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_entity_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_operation_type.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: ChecklistsRepository)
final class ChecklistsRepositoryImpl implements ChecklistsRepository {
  ChecklistsRepositoryImpl({
    required InternetClient internet,
    required ChecklistsRemoteDataSource remoteDataSource,
    required ChecklistsLocalDataSource localDataSource,
    required SyncRepository syncRepository,
    required SessionRepository sessionRepository,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _syncRepository = syncRepository,
       _sessionRepository = sessionRepository;

  final InternetClient _internet;
  final ChecklistsRemoteDataSource _remoteDataSource;
  final ChecklistsLocalDataSource _localDataSource;
  final SyncRepository _syncRepository;
  final SessionRepository _sessionRepository;


  @override
  FutureList<ChecklistTemplateEntity> getTemplates(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ChecklistTemplateModel,
        ChecklistTemplateEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getTemplates(companyId),
        remoteCallback: () => _remoteDataSource.getTemplates(companyId),
        onRemoteSuccess: (list) async {
          await Future.wait(list.map(_localDataSource.saveTemplate).toList());
          // Cache the embedded items too, so an order whose template was never
          // opened still renders its checklist offline.
          await Future.wait([
            for (final template in list)
              for (final item in template.items)
                _localDataSource.saveItem(ChecklistItemModel.fromEntity(item)),
          ]);
          return const SuccessState(data: true);
        },
      );

  @override
  FutureData<ChecklistTemplateEntity> getTemplateById(String id) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        ChecklistTemplateModel,
        ChecklistTemplateEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getTemplateById(id),
        remoteCallback: () => _remoteDataSource.getTemplateById(id),
        onRemoteSuccess: _localDataSource.saveTemplate,
      );

  @override
  FutureBool createTemplate(ChecklistTemplateEntity template) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final model = ChecklistTemplateModel.fromEntity(template);
          final result = await _remoteDataSource.createTemplate(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveTemplate(model);
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
  FutureBool updateTemplate(ChecklistTemplateEntity template) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final model = ChecklistTemplateModel.fromEntity(template);
          final result = await _remoteDataSource.updateTemplate(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveTemplate(model);
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
  FutureBool deleteTemplate(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteTemplate(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deleteTemplate(id);
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
  Stream<RealtimeEvent<ChecklistTemplateEntity>>
  watchChecklistTemplatesRealtime({String? companyId}) {
    return _remoteDataSource
        .watchChecklistTemplatesRealtime(companyId: companyId)
        .asyncMap((event) async {
          if (event.entity != null &&
              (event.eventType == RealtimeEventType.insert ||
                  event.eventType == RealtimeEventType.update)) {
            if (event.entity!.deletedAt != null) {
              await _localDataSource.deleteTemplate(event.id);
            } else {
              await _localDataSource.saveTemplate(event.entity!);
            }
          } else if (event.eventType == RealtimeEventType.delete &&
              event.id.isNotEmpty) {
            await _localDataSource.deleteTemplate(event.id);
          }

          return RealtimeEvent<ChecklistTemplateEntity>(
            eventType: event.eventType,
            id: event.id,
            companyId: event.companyId,
            entity: event.entity,
          );
        });
  }

  @override
  FutureList<ChecklistItemEntity> getItemsByTemplate(String templateId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ChecklistItemModel,
        ChecklistItemEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getItemsByTemplate(templateId),
        remoteCallback: () => _remoteDataSource.getItemsByTemplate(templateId),
        onRemoteSuccess: (list) async {
          await Future.wait(list.map(_localDataSource.saveItem).toList());
          return const SuccessState(data: true);
        },
      );

  @override
  FutureBool createItem(ChecklistItemEntity item) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final model = ChecklistItemModel.fromEntity(item);
          final result = await _remoteDataSource.createItem(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveItem(model);
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
  FutureBool updateItem(ChecklistItemEntity item) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () async {
          final model = ChecklistItemModel.fromEntity(item);
          final result = await _remoteDataSource.updateItem(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveItem(model);
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
  FutureBool deleteItem(String id) => RepositoryHandler.fetchWithFallback<bool>(
    isInternetConnected: _internet.isConnected,
    remoteCallback: () async {
      final result = await _remoteDataSource.deleteItem(id);
      if (result is SuccessState<void>) {
        await _localDataSource.deleteItem(id);
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
  Stream<RealtimeEvent<ChecklistItemEntity>> watchChecklistItemsRealtime({
    String? companyId,
  }) {
    return _remoteDataSource
        .watchChecklistItemsRealtime(companyId: companyId)
        .asyncMap((event) async {
          if (event.entity != null &&
              (event.eventType == RealtimeEventType.insert ||
                  event.eventType == RealtimeEventType.update)) {
            if (event.entity!.deletedAt != null) {
              await _localDataSource.deleteItem(event.id);
            } else {
              await _localDataSource.saveItem(event.entity!);
            }
          } else if (event.eventType == RealtimeEventType.delete &&
              event.id.isNotEmpty) {
            await _localDataSource.deleteItem(event.id);
          }

          return RealtimeEvent<ChecklistItemEntity>(
            eventType: event.eventType,
            id: event.id,
            companyId: event.companyId,
            entity: event.entity,
          );
        });
  }

  @override
  FutureList<ChecklistAnswerEntity> getResponsesByWorkOrder(
    String workOrderId,
  ) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        ChecklistAnswerModel,
        ChecklistAnswerEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () =>
            _localDataSource.getResponsesByWorkOrder(workOrderId),
        remoteCallback: () =>
            _remoteDataSource.getResponsesByWorkOrder(workOrderId),
        onRemoteSuccess: (list) async {
          await Future.wait(list.map(_localDataSource.saveResponse).toList());
          return const SuccessState(data: true);
        },
      );

  @override
  Stream<RealtimeEvent<ChecklistAnswerEntity>> watchChecklistAnswersRealtime({
    required String workOrderId,
  }) {
    return _remoteDataSource
        .watchChecklistAnswersRealtime(workOrderId: workOrderId)
        .asyncMap((event) async {
          if (event.entity != null &&
              (event.eventType == RealtimeEventType.insert ||
                  event.eventType == RealtimeEventType.update)) {
            await _localDataSource.saveResponse(
              ChecklistAnswerModel.fromEntity(event.entity!),
            );
          }

          return RealtimeEvent<ChecklistAnswerEntity>(
            eventType: event.eventType,
            id: event.id,
            companyId: event.companyId,
            entity: event.entity,
          );
        });
  }

  @override
  FutureBool saveResponse(ChecklistAnswerEntity response) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () async {
          final model = ChecklistAnswerModel.fromEntity(response);
          final result = await _localDataSource.saveResponse(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _syncRepository.enqueue(
              SyncQueueItemEntity(
                id: const Uuid().v4(),
                companyId: _sessionRepository.getSelectedCompanyId() ?? '',
                userProfileId: _sessionRepository.userData.user.id,
                entityType: SyncEntityType.checklistAnswer,
                entityId: response.id,
                operation: SyncOperationType.update,
                payload: jsonEncode(model.toJson()),
                createdAt: DateTime.now(),
              ),
            );
          }
          return result;
        },
        remoteCallback: () async {
          final model = ChecklistAnswerModel.fromEntity(response);
          final result = await _remoteDataSource.saveResponse(model);
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.saveResponse(model);
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
