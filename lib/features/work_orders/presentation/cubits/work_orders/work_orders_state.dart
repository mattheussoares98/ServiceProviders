part of 'work_orders_cubit.dart';

class WorkOrdersState extends BaseState {
  const WorkOrdersState({
    required this.workOrders,
    required this.changeRequests,
    required this.historyByWorkOrder,
    this.activeFilter = const WorkOrderFilter(),
    this.hasMorePages = true,
    this.isLoadingMore = false,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const WorkOrdersState.initial()
    : workOrders = const [],
      changeRequests = const [],
      historyByWorkOrder = const <String, List<WorkOrderHistoryEntity>>{},
      activeFilter = const WorkOrderFilter(),
      hasMorePages = true,
      isLoadingMore = false,
      super(status: StateStatus.initial, errorMessage: '');

  final List<WorkOrderEntity> workOrders;
  final List<WorkOrderChangeRequestEntity> changeRequests;
  final Map<String, List<WorkOrderHistoryEntity>> historyByWorkOrder;
  final WorkOrderFilter activeFilter;
  final bool hasMorePages;
  final bool isLoadingMore;

  WorkOrdersState copyWith({
    List<WorkOrderEntity>? workOrders,
    List<WorkOrderChangeRequestEntity>? changeRequests,
    Map<String, List<WorkOrderHistoryEntity>>? historyByWorkOrder,
    WorkOrderFilter? activeFilter,
    bool? hasMorePages,
    bool? isLoadingMore,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return WorkOrdersState(
      workOrders: workOrders ?? this.workOrders,
      changeRequests: changeRequests ?? this.changeRequests,
      historyByWorkOrder: historyByWorkOrder ?? this.historyByWorkOrder,
      activeFilter: activeFilter ?? this.activeFilter,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
      errorMessage: annulErrorMessage == true
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    workOrders,
    changeRequests,
    historyByWorkOrder,
    activeFilter,
    hasMorePages,
    isLoadingMore,
    status,
    errorMessage,
  ];
}
