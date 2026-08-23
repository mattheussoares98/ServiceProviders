import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/repositories/sync_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/get_pending_sync_count_use_case.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/process_sync_queue_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

abstract interface class SyncEngine {
  bool get isSyncing;
  Stream<void> get onSyncCompleted;
  void init();
  void dispose();
  Future<int> processQueue();
  Stream<List<SyncQueueItemEntity>> watchDeadLetterItemsForEntity(
    String entityId,
  );
  Future<void> retryEntity(String entityId);
}

@LazySingleton(as: SyncEngine)
final class SyncEngineImpl implements SyncEngine {
  SyncEngineImpl({
    required InternetClient internetClient,
    required ProcessSyncQueueUseCase processSyncQueueUseCase,
    required GetPendingSyncCountUseCase getPendingSyncCountUseCase,
    required WorkOrdersRepository workOrdersRepository,
    required SessionRepository sessionRepository,
    required SyncRepository syncRepository,
  }) : _internetClient = internetClient,
       _processSyncQueueUseCase = processSyncQueueUseCase,
       _getPendingSyncCountUseCase = getPendingSyncCountUseCase,
       _workOrdersRepository = workOrdersRepository,
       _sessionRepository = sessionRepository,
       _syncRepository = syncRepository;

  final InternetClient _internetClient;
  final ProcessSyncQueueUseCase _processSyncQueueUseCase;
  final GetPendingSyncCountUseCase _getPendingSyncCountUseCase;
  final WorkOrdersRepository _workOrdersRepository;
  final SessionRepository _sessionRepository;
  final SyncRepository _syncRepository;

  final _syncCompletedController = StreamController<void>.broadcast();
  StreamSubscription<InternetStatus>? _subscription;
  Timer? _retryTimer;
  bool _isSyncing = false;

  @override
  bool get isSyncing => _isSyncing;

  @override
  Stream<void> get onSyncCompleted => _syncCompletedController.stream;

  @override
  void init() {
    _subscription = _internetClient.connectivityStream?.listen((status) {
      if (status == InternetStatus.connected) {
        processQueue();
      }
    });

    if (_internetClient.isConnected) {
      processQueue();
    }

    _retryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_internetClient.isConnected && !_isSyncing) {
        processQueue();
      }
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _subscription?.cancel();
    _syncCompletedController.close();
  }

  @override
  Future<int> processQueue() async {
    if (_isSyncing || !_internetClient.isConnected) {
      return 0;
    }

    final isProvider =
        AppMode.fromName(_sessionRepository.getSelectedMode()) ==
        AppMode.provider;
    if (isProvider) {
      return 0;
    }

    _isSyncing = true;

    try {
      final result = await _processSyncQueueUseCase();
      final count = result is SuccessState<int> ? result.data ?? 0 : 0;

      // Check if there are no more pending sync items in the queue
      final pendingResult = await _getPendingSyncCountUseCase();
      final hasNoPending =
          pendingResult is SuccessState<int> && (pendingResult.data ?? 0) == 0;

      if (hasNoPending) {
        final companyId = _sessionRepository.getSelectedCompanyId();
        if (companyId != null && companyId.isNotEmpty) {
          await _workOrdersRepository.syncWorkOrders(companyId);
        }

        if (!_syncCompletedController.isClosed) {
          _syncCompletedController.add(null);
        }
      }

      return count;
    } finally {
      _isSyncing = false;
    }
  }

  @override
  Stream<List<SyncQueueItemEntity>> watchDeadLetterItemsForEntity(
    String entityId,
  ) =>
      _syncRepository.watchDeadLetterItemsForEntity(entityId);

  @override
  Future<void> retryEntity(String entityId) async {
    await _syncRepository.retryDeadLetterForEntity(entityId);
    await processQueue();
  }
}
