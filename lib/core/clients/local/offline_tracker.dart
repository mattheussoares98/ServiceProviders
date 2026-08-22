import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/constants/offline_limits.dart';

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
  bool recordOfflineAction();
  bool checkStartupOrResumeStatus();
  void reset();
}

@LazySingleton(as: OfflineTracker)
final class OfflineTrackerImpl implements OfflineTracker {
  OfflineTrackerImpl({required InternetClient internetClient})
    : _internetClient = internetClient;

  final InternetClient _internetClient;
  final _alertController = StreamController<OfflineAdvisoryEvent>.broadcast();
  StreamSubscription<InternetStatus>? _subscription;

  DateTime? _offlineSince;
  int _offlineMutationCount = 0;
  int _lastAlertMutationCount = 0;

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
  Duration get offlineDuration =>
      _offlineSince != null
          ? DateTime.now().difference(_offlineSince!)
          : Duration.zero;

  @override
  bool get hasBreachedDuration =>
      _offlineSince != null &&
      offlineDuration.inHours >= kMaxOfflineDurationHours;

  @override
  bool get hasBreachedRequests =>
      _offlineMutationCount >= kMaxOfflinePendingRequests;

  @override
  bool get isThresholdBreached => hasBreachedDuration || hasBreachedRequests;

  @override
  void init() {
    if (isOffline && _offlineSince == null) {
      _offlineSince = DateTime.now();
    }

    _subscription = _internetClient.connectivityStream?.listen((status) {
      if (status == InternetStatus.connected) {
        reset();
      } else if (status == InternetStatus.disconnected) {
        _offlineSince ??= DateTime.now();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _alertController.close();
  }

  /// Increments offline action counter and returns true if an advisory alert should be shown.
  @override
  bool recordOfflineAction() {
    if (!isOffline) return false;

    _offlineSince ??= DateTime.now();
    _offlineMutationCount++;

    if (!isThresholdBreached) return false;

    // First time threshold is breached
    if (_lastAlertMutationCount == 0) {
      _lastAlertMutationCount = _offlineMutationCount;
      _emitAlert(OfflineAdvisoryTrigger.action);
      return true;
    }

    // Throttle: alert every [kOfflineAlertThrottleFrequency] subsequent actions
    if ((_offlineMutationCount - _lastAlertMutationCount) >=
        kOfflineAlertThrottleFrequency) {
      _lastAlertMutationCount = _offlineMutationCount;
      _emitAlert(OfflineAdvisoryTrigger.action);
      return true;
    }

    return false;
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
