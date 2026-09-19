import 'dart:async';

import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/constants/offline_limits.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/repositories/session_repository.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';

enum OfflineAdvisoryTrigger { startup, action }

final class OfflineAdvisoryEvent {
  const OfflineAdvisoryEvent({
    required this.trigger,
    required this.offlineDuration,
    required this.pendingMutationCount,
    required this.hasBreachedDuration,
    required this.hasBreachedRequests,
  });

  final OfflineAdvisoryTrigger trigger;
  final Duration offlineDuration;
  final int pendingMutationCount;
  final bool hasBreachedDuration;
  final bool hasBreachedRequests;
}

abstract interface class OfflineTracker {
  DateTime? get offlineSince;
  int get offlineMutationCount;
  int get lastAlertMutationCount;
  bool get isOffline;
  Duration get offlineDuration;
  bool get hasBreachedDuration;
  bool get hasBreachedRequests;
  bool get isThresholdBreached;
  Stream<OfflineAdvisoryEvent> get alertStream;

  void init();
  void dispose();
  bool checkStartupOrResumeStatus();
  void reset();
}

@LazySingleton(as: OfflineTracker)
final class OfflineTrackerImpl implements OfflineTracker {
  OfflineTrackerImpl({
    required InternetClient internetClient,
    required AppDatabase database,
    required SessionRepository sessionRepository,
    required GetActiveCompanyIdUseCase getActiveCompanyId,
  }) : _internetClient = internetClient,
       _database = database,
       _sessionRepository = sessionRepository,
       _getActiveCompanyId = getActiveCompanyId;

  final InternetClient _internetClient;
  final AppDatabase _database;
  final SessionRepository _sessionRepository;
  final GetActiveCompanyIdUseCase _getActiveCompanyId;
  final _alertController = StreamController<OfflineAdvisoryEvent>.broadcast();
  StreamSubscription<InternetStatus>? _connectivitySubscription;
  StreamSubscription<int>? _dbSubscription;
  StreamSubscription<CompanyParameter?>? _paramsSubscription;
  StreamSubscription<UserDataEntity>? _sessionSubscription;
  StreamSubscription<AppSetting?>? _settingsSubscription;
  ({String companyId, String userId})? _context;
  bool _initialized = false;
  bool _disposed = false;

  DateTime? _offlineSince;
  int _offlineMutationCount = 0;
  int _lastAlertMutationCount = 0;

  int _maxOfflineDurationHours = kMaxOfflineDurationHours;
  int _maxOfflinePendingRequests = kMaxOfflinePendingRequests;
  int _offlineAlertThrottleFrequency = kOfflineAlertThrottleFrequency;

  @override
  Stream<OfflineAdvisoryEvent> get alertStream => _alertController.stream;

  @override
  DateTime? get offlineSince => _offlineSince;

  @override
  int get offlineMutationCount => _offlineMutationCount;

  @override
  int get lastAlertMutationCount => _lastAlertMutationCount;

  @override
  bool get isOffline => !_internetClient.isConnected;

  @override
  Duration get offlineDuration => _offlineSince != null
      ? DateTime.now().difference(_offlineSince!)
      : Duration.zero;

  @override
  bool get hasBreachedDuration =>
      _offlineSince != null &&
      offlineDuration.inHours >= _maxOfflineDurationHours;

  @override
  bool get hasBreachedRequests =>
      _offlineMutationCount >= _maxOfflinePendingRequests;

  @override
  bool get isThresholdBreached => hasBreachedDuration || hasBreachedRequests;

  @override
  void init() {
    if (_initialized || _disposed) return;
    _initialized = true;

    if (isOffline && _offlineSince == null) {
      _offlineSince = DateTime.now();
    }

    _watchActiveCompany();
    _sessionSubscription = _sessionRepository.sessionStream.listen(
      (_) => _watchActiveCompany(),
    );
    _settingsSubscription =
        (_database.select(_database.appSettings)
              ..where((settings) => settings.id.equals(1)))
            .watchSingleOrNull()
            .listen((_) => _watchActiveCompany());

    _connectivitySubscription = _internetClient.connectivityStream?.listen((
      status,
    ) {
      if (status == InternetStatus.connected) {
        reset();
      } else if (status == InternetStatus.disconnected) {
        _offlineSince ??= DateTime.now();
      }
    });
  }

  void _watchActiveCompany() {
    if (_disposed) return;
    final session = _sessionRepository.userData;
    final hasSession =
        session.user.id.isNotEmpty && session.accessToken.isNotEmpty;
    final context = (
      companyId: hasSession ? _getActiveCompanyId() : '',
      userId: hasSession ? session.user.id : '',
    );
    if (_context == context) return;
    _context = context;
    _paramsSubscription?.cancel();
    _dbSubscription?.cancel();
    _dbSubscription = null;
    _offlineMutationCount = 0;
    _lastAlertMutationCount = 0;
    _applyParameters(null);

    if (context.companyId.isEmpty || context.userId.isEmpty) return;

    _paramsSubscription =
        (_database.select(_database.companyParameters)..where(
              (params) =>
                  params.companyId.equals(context.companyId) &
                  params.deletedAt.isNull(),
            ))
            .watchSingleOrNull()
            .listen((params) {
              if (_disposed || _context != context) return;
              _applyParameters(params);
              // Load limits before evaluating the initial pending queue.
              _dbSubscription ??= _watchPendingMutations(context);
            });
  }

  void _applyParameters(CompanyParameter? params) {
    _maxOfflineDurationHours =
        params?.maxOfflineDurationHours ?? kMaxOfflineDurationHours;
    _maxOfflinePendingRequests =
        params?.maxOfflinePendingRequests ?? kMaxOfflinePendingRequests;
    _offlineAlertThrottleFrequency =
        params?.offlineAlertThrottleFrequency ?? kOfflineAlertThrottleFrequency;
  }

  StreamSubscription<int> _watchPendingMutations(
    ({String companyId, String userId}) context,
  ) {
    final countExp = _database.syncAuditLogs.id.count();
    final query = _database.selectOnly(_database.syncAuditLogs)
      ..addColumns([countExp])
      ..where(
        _database.syncAuditLogs.companyId.equals(context.companyId) &
            _database.syncAuditLogs.userProfileId.equals(context.userId) &
            (_database.syncAuditLogs.status.equals('pending') |
                _database.syncAuditLogs.status.equals('syncing')),
      );

    return query.watchSingle().map((row) => row.read(countExp) ?? 0).listen((
      count,
    ) {
      if (!_disposed && _context == context) _onPendingCountChanged(count);
    });
  }

  void _onPendingCountChanged(int count) {
    final previousCount = _offlineMutationCount;
    _offlineMutationCount = count;

    if (!isOffline) return;

    if (count > previousCount) {
      _offlineSince ??= DateTime.now();

      if (isThresholdBreached) {
        // First time threshold is breached
        if (_lastAlertMutationCount == 0) {
          _lastAlertMutationCount = _offlineMutationCount;
          _emitAlert(OfflineAdvisoryTrigger.action);
        } else if ((_offlineMutationCount - _lastAlertMutationCount) >=
            _offlineAlertThrottleFrequency) {
          _lastAlertMutationCount = _offlineMutationCount;
          _emitAlert(OfflineAdvisoryTrigger.action);
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _connectivitySubscription?.cancel();
    _dbSubscription?.cancel();
    _paramsSubscription?.cancel();
    _sessionSubscription?.cancel();
    _settingsSubscription?.cancel();
    _alertController.close();
  }

  /// Evaluates status on app startup or resume from background.
  @override
  bool checkStartupOrResumeStatus() {
    if (!isOffline) return false;

    _offlineSince ??= DateTime.now();

    if (isThresholdBreached) {
      _lastAlertMutationCount = _offlineMutationCount;
      _emitAlert(OfflineAdvisoryTrigger.startup);
      return true;
    }
    return false;
  }

  void _emitAlert(OfflineAdvisoryTrigger trigger) {
    if (!_alertController.isClosed) {
      _alertController.add(
        OfflineAdvisoryEvent(
          trigger: trigger,
          offlineDuration: offlineDuration,
          pendingMutationCount: _offlineMutationCount,
          hasBreachedDuration: hasBreachedDuration,
          hasBreachedRequests: hasBreachedRequests,
        ),
      );
    }
  }

  @override
  void reset() {
    _offlineSince = null;
    _offlineMutationCount = 0;
    _lastAlertMutationCount = 0;
  }
}
