part of 'dashboard_cubit.dart';

class DashboardState extends BaseState {
  const DashboardState({
    super.status,
    required this.openWorkOrdersCount,
    required this.inProgressWorkOrdersCount,
    required this.pendingRevisionsCount,
    required this.recentWorkOrders,
    this.userProfile,
    this.activeWorkOrder,
    super.errorMessage,
  });

  const DashboardState.initial()
    : openWorkOrdersCount = 0,
      inProgressWorkOrdersCount = 0,
      pendingRevisionsCount = 0,
      recentWorkOrders = const [],
      userProfile = null,
      activeWorkOrder = null,
      super(status: StateStatus.initial);

  final int openWorkOrdersCount;
  final int inProgressWorkOrdersCount;
  final int pendingRevisionsCount;
  final List<WorkOrderEntity> recentWorkOrders;
  final UserProfileEntity? userProfile;
  final WorkOrderEntity? activeWorkOrder;

  DashboardState copyWith({
    StateStatus? status,
    int? openWorkOrdersCount,
    int? inProgressWorkOrdersCount,
    int? pendingRevisionsCount,
    List<WorkOrderEntity>? recentWorkOrders,
    UserProfileEntity? userProfile,
    WorkOrderEntity? activeWorkOrder,
    String? errorMessage,
    bool? annulErrorMessage,
    bool? annulUserProfile,
    bool? annulActiveWorkOrder,
  }) {
    return DashboardState(
      status: status ?? this.status,
      openWorkOrdersCount: openWorkOrdersCount ?? this.openWorkOrdersCount,
      inProgressWorkOrdersCount:
          inProgressWorkOrdersCount ?? this.inProgressWorkOrdersCount,
      pendingRevisionsCount:
          pendingRevisionsCount ?? this.pendingRevisionsCount,
      recentWorkOrders: recentWorkOrders ?? this.recentWorkOrders,
      userProfile: annulUserProfile == true
          ? null
          : userProfile ?? this.userProfile,
      activeWorkOrder: annulActiveWorkOrder == true
          ? null
          : activeWorkOrder ?? this.activeWorkOrder,
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
    userProfile,
    activeWorkOrder,
    errorMessage,
  ];
}


