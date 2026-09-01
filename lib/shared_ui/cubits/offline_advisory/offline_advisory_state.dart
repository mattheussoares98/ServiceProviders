import 'package:o_jogo_da_obra/core/clients/local/offline_tracker.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

final class OfflineAdvisoryState extends BaseState {
  const OfflineAdvisoryState({
    super.status = DataStatus.initial,
    super.errorMessage,
    super.sections,
    this.advisoryEvent,
    this.isProviderBlocked = false,
  });

  final OfflineAdvisoryEvent? advisoryEvent;
  final bool isProviderBlocked;

  bool get shouldShowDialog => advisoryEvent != null;

  OfflineAdvisoryState copyWith({
    DataStatus? status,
    String? errorMessage,
    OfflineAdvisoryEvent? advisoryEvent,
    bool annulAdvisoryEvent = false,
    bool? isProviderBlocked,
  }) {
    return OfflineAdvisoryState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      sections: sections,
      advisoryEvent: annulAdvisoryEvent
          ? null
          : (advisoryEvent ?? this.advisoryEvent),
      isProviderBlocked: isProviderBlocked ?? this.isProviderBlocked,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    sections,
    advisoryEvent,
    isProviderBlocked,
  ];
}
