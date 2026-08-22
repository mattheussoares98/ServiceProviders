import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

final class OfflineAdvisoryState extends BaseState {
  const OfflineAdvisoryState({
    super.status = StateStatus.initial,
    super.errorMessage,
    super.sections,
    this.advisoryEvent,
  });

  final OfflineAdvisoryEvent? advisoryEvent;

  bool get shouldShowDialog => advisoryEvent != null;

  OfflineAdvisoryState copyWith({
    StateStatus? status,
    String? errorMessage,
    OfflineAdvisoryEvent? advisoryEvent,
    bool annulAdvisoryEvent = false,
  }) {
    return OfflineAdvisoryState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      sections: sections,
      advisoryEvent:
          annulAdvisoryEvent ? null : (advisoryEvent ?? this.advisoryEvent),
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, sections, advisoryEvent];
}
