part of 'dashboard_cubit.dart';

class DashboardState extends BaseState {
  const DashboardState({
    super.status,
    required this.openWorkOrdersCount,
    required this.inProgressWorkOrdersCount,
    required this.pendingRevisionsCount,
    required this.recentWorkOrders,
    this.userProfile,
    this.activeWorkOrders = const [],
    super.errorMessage,
  });

  const DashboardState.initial()
    : openWorkOrdersCount = 0,
      inProgressWorkOrdersCount = 0,
      pendingRevisionsCount = 0,
      recentWorkOrders = const [],
      userProfile = null,
      activeWorkOrders = const [],
      super(status: StateStatus.initial);

  final int openWorkOrdersCount;
  final int inProgressWorkOrdersCount;
  final int pendingRevisionsCount;
  final List<WorkOrderEntity> recentWorkOrders;
  final UserProfileEntity? userProfile;
  final List<WorkOrderEntity> activeWorkOrders;

  WorkOrderEntity? get activeWorkOrder => activeWorkOrders.firstOrNull;

  DashboardState copyWith({
    StateStatus? status,
    int? openWorkOrdersCount,
    int? inProgressWorkOrdersCount,
    int? pendingRevisionsCount,
    List<WorkOrderEntity>? recentWorkOrders,
    UserProfileEntity? userProfile,
    List<WorkOrderEntity>? activeWorkOrders,
    WorkOrderEntity? activeWorkOrder,
    String? errorMessage,
    bool? annulErrorMessage,
    bool? annulUserProfile,
    bool? annulActiveWorkOrders,
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
      activeWorkOrders: annulActiveWorkOrders == true
          ? const []
          : activeWorkOrders ?? this.activeWorkOrders,
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
    activeWorkOrders,
    errorMessage,
  ];
}
