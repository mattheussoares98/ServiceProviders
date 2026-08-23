import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/sync/domain/use_cases/process_sync_queue_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/work_orders_repository.dart';

abstract interface class SyncEngine {
  bool get isSyncing;
  void init();
  void dispose();
  Future<int> processQueue();
}

@LazySingleton(as: SyncEngine)
final class SyncEngineImpl implements SyncEngine {
  SyncEngineImpl({
    required InternetClient internetClient,
    required ProcessSyncQueueUseCase processSyncQueueUseCase,
    required WorkOrdersRepository workOrdersRepository,
    required SessionRepository sessionRepository,
  }) : _internetClient = internetClient,
       _processSyncQueueUseCase = processSyncQueueUseCase,
       _workOrdersRepository = workOrdersRepository,
       _sessionRepository = sessionRepository;

  final InternetClient _internetClient;
  final ProcessSyncQueueUseCase _processSyncQueueUseCase;
  final WorkOrdersRepository _workOrdersRepository;
  final SessionRepository _sessionRepository;

  StreamSubscription<InternetStatus>? _subscription;
  bool _isSyncing = false;

  @override
  bool get isSyncing => _isSyncing;

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
  }

  @override
  void dispose() {
    _subscription?.cancel();
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

      // After outbound queue is processed, trigger inbound delta sync
      final companyId = _sessionRepository.getSelectedCompanyId();
      if (companyId != null && companyId.isNotEmpty) {
        await _workOrdersRepository.syncWorkOrders(companyId);
      }

      return count;
    } finally {
      _isSyncing = false;
    }
  }
}
