import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/offline_advisory/offline_advisory_state.dart';

@injectable
class OfflineAdvisoryCubit extends BaseCubit<OfflineAdvisoryState> {
  OfflineAdvisoryCubit({required OfflineTracker offlineTracker})
    : _offlineTracker = offlineTracker,
      super(const OfflineAdvisoryState()) {
    _subscription = _offlineTracker.alertStream.listen(_onAlertEvent);
  }

  final OfflineTracker _offlineTracker;
  StreamSubscription<OfflineAdvisoryEvent>? _subscription;

  void _onAlertEvent(OfflineAdvisoryEvent event) {
    emit(state.copyWith(
      status: StateStatus.loaded,
      advisoryEvent: event,
    ));
  }

  /// Validates offline status on app startup or when resumed from background.
  void checkStartupOrResume() {
    _offlineTracker.checkStartupOrResumeStatus();
  }

  /// Dismisses the active advisory dialog.
  void dismissAlert() {
    emit(state.copyWith(annulAdvisoryEvent: true));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
