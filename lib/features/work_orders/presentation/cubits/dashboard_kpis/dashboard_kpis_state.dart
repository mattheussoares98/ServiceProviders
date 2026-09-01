part of 'dashboard_kpis_cubit.dart';

class DashboardKpisState extends BaseState {
  const DashboardKpisState({
    required this.metrics,
    this.startDate,
    this.endDate,
    super.status = DataStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  const DashboardKpisState.initial()
    : metrics = const WorkOrderKpiMetricsEntity.empty(),
      startDate = null,
      endDate = null,
      super(status: DataStatus.initial, errorMessage: '');

  final WorkOrderKpiMetricsEntity metrics;
  final DateTime? startDate;
  final DateTime? endDate;

  DashboardKpisState copyWith({
    WorkOrderKpiMetricsEntity? metrics,
    DateTime? startDate,
    bool? annulStartDate,
    DateTime? endDate,
    bool? annulEndDate,
    DataStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
    Map<SectionKey, SectionStatus>? sections,
  }) {
    return DashboardKpisState(
      metrics: metrics ?? this.metrics,
      startDate: annulStartDate == true ? null : startDate ?? this.startDate,
      endDate: annulEndDate == true ? null : endDate ?? this.endDate,
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
    startDate,
    endDate,
    status,
    errorMessage,
    sections,
  ];
}
