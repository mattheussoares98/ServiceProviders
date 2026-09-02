import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_state.dart';

@injectable
class OfflineAdvisoryCubit extends BaseCubit<OfflineAdvisoryState> {
  OfflineAdvisoryCubit({
    required OfflineTracker offlineTracker,
    required InternetClient internetClient,
    required GetSelectedModeUseCase getSelectedMode,
  }) : _offlineTracker = offlineTracker,
       _internetClient = internetClient,
       _getSelectedMode = getSelectedMode,
       super(const OfflineAdvisoryState()) {
    _offlineTrackerSubscription = _offlineTracker.alertStream.listen(
      _onAlertEvent,
    );
    _subscribeConnectivityIfNeeded();
  }

  final OfflineTracker _offlineTracker;
  final InternetClient _internetClient;
  final GetSelectedModeUseCase _getSelectedMode;
  StreamSubscription<OfflineAdvisoryEvent>? _offlineTrackerSubscription;
  StreamSubscription<InternetStatus>? _connectivitySubscription;

  void _onAlertEvent(OfflineAdvisoryEvent event) {
    emit(state.copyWith(advisoryEvent: event));
  }

  void _onConnectivityChanged(InternetStatus status) {
    checkProviderConnectivity();
  }

  void _subscribeConnectivityIfNeeded() {
    _connectivitySubscription ??= _internetClient.connectivityStream?.listen(
      _onConnectivityChanged,
    );
  }

  /// Validates offline status on app startup or when resumed from background.
  void checkStartupOrResume() {
    _subscribeConnectivityIfNeeded();
    _offlineTracker.checkStartupOrResumeStatus();
    checkProviderConnectivity();
  }

  /// Checks if the active mode is provider and the device is offline to block interaction.
  void checkProviderConnectivity({AppMode? activeMode}) {
    final mode = activeMode ?? AppMode.fromName(_getSelectedMode.call());
    final isProvider = mode == AppMode.provider;
    final isOffline = !_internetClient.isConnected;
    final shouldBlock = isProvider && isOffline;

    if (state.isProviderBlocked != shouldBlock) {
      emit(state.copyWith(isProviderBlocked: shouldBlock));
    }
  }

  /// Retries checking the internet connection and updates blocking status.
  Future<bool> retryConnection() async {
    final isConnected = await _internetClient.checkConnection();
    checkProviderConnectivity();
    return isConnected;
  }

  /// Dismisses the active advisory dialog.
  void dismissAlert() {
    emit(state.copyWith(annulAdvisoryEvent: true));
  }

  @override
  Future<void> close() {
    _offlineTrackerSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
