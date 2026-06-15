part of 'dashboard_cubit.dart';

class DashboardState extends BaseState {
  const DashboardState({
    super.status,
    required this.openWorkOrdersCount,
    required this.inProgressWorkOrdersCount,
    required this.pendingRevisionsCount,
    required this.recentWorkOrders,
    super.errorMessage,
  });

  const DashboardState.initial()
    : openWorkOrdersCount = 0,
      inProgressWorkOrdersCount = 0,
      pendingRevisionsCount = 0,
      recentWorkOrders = const [],
      super(status: StateStatus.initial);

  final int openWorkOrdersCount;
  final int inProgressWorkOrdersCount;
  final int pendingRevisionsCount;
  final List<WorkOrderEntity> recentWorkOrders;

  DashboardState copyWith({
    StateStatus? status,
    int? openWorkOrdersCount,
    int? inProgressWorkOrdersCount,
    int? pendingRevisionsCount,
    List<WorkOrderEntity>? recentWorkOrders,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      openWorkOrdersCount: openWorkOrdersCount ?? this.openWorkOrdersCount,
      inProgressWorkOrdersCount:
          inProgressWorkOrdersCount ?? this.inProgressWorkOrdersCount,
      pendingRevisionsCount:
          pendingRevisionsCount ?? this.pendingRevisionsCount,
      recentWorkOrders: recentWorkOrders ?? this.recentWorkOrders,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    openWorkOrdersCount,
    inProgressWorkOrdersCount,
    pendingRevisionsCount,
    recentWorkOrders,
    errorMessage,
  ];
}
