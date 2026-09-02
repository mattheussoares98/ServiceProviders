import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

final class OfflineAdvisoryState extends BaseState {
  const OfflineAdvisoryState({
    super.sections,
    this.advisoryEvent,
    this.isProviderBlocked = false,
  });

  final OfflineAdvisoryEvent? advisoryEvent;
  final bool isProviderBlocked;

  bool get shouldShowDialog => advisoryEvent != null;

  OfflineAdvisoryState copyWith({
    OfflineAdvisoryEvent? advisoryEvent,
    bool annulAdvisoryEvent = false,
    bool? isProviderBlocked,
    Map<SectionKey, SectionState>? sections,
  }) {
    return OfflineAdvisoryState(
      sections: sections ?? this.sections,
      advisoryEvent: annulAdvisoryEvent
          ? null
          : (advisoryEvent ?? this.advisoryEvent),
      isProviderBlocked: isProviderBlocked ?? this.isProviderBlocked,
    );
  }

  @override
  List<Object?> get props => [sections, advisoryEvent, isProviderBlocked];
}
