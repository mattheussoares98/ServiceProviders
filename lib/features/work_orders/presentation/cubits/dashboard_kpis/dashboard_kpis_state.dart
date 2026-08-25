part of 'dashboard_kpis_cubit.dart';

class DashboardKpisState extends BaseState {
  const DashboardKpisState({
    required this.metrics,
    this.selectedPeriod = KpiPeriod.last30Days,
    super.status = StateStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  const DashboardKpisState.initial()
    : metrics = const WorkOrderKpiMetricsEntity.empty(),
      selectedPeriod = KpiPeriod.last30Days,
      super(status: StateStatus.initial, errorMessage: '');

  final WorkOrderKpiMetricsEntity metrics;
  final KpiPeriod selectedPeriod;

  DashboardKpisState copyWith({
    WorkOrderKpiMetricsEntity? metrics,
    KpiPeriod? selectedPeriod,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, StateStatus>? sections,
  }) {
    return DashboardKpisState(
      metrics: metrics ?? this.metrics,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    metrics,
    selectedPeriod,
    status,
    errorMessage,
    sections,
  ];
}
