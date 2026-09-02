part of 'dashboard_kpis_cubit.dart';

class DashboardKpisState extends BaseState {
  const DashboardKpisState({
    required this.metrics,
    this.startDate,
    this.endDate,
    super.sections = const {},
  });

  const DashboardKpisState.initial()
    : metrics = const WorkOrderKpiMetricsEntity.empty(),
      startDate = null,
      endDate = null,
      super();

  final WorkOrderKpiMetricsEntity metrics;
  final DateTime? startDate;
  final DateTime? endDate;

  DashboardKpisState copyWith({
    WorkOrderKpiMetricsEntity? metrics,
    DateTime? startDate,
    bool? annulStartDate,
    DateTime? endDate,
    bool? annulEndDate,
    Map<SectionKey, SectionState>? sections,
  }) {
    return DashboardKpisState(
      metrics: metrics ?? this.metrics,
      startDate: annulStartDate == true ? null : startDate ?? this.startDate,
      endDate: annulEndDate == true ? null : endDate ?? this.endDate,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [metrics, startDate, endDate, sections];
}
