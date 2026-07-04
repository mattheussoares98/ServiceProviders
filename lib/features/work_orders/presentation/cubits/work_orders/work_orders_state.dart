part of 'work_orders_cubit.dart';

class WorkOrdersState extends BaseState {
  const WorkOrdersState({
    required this.workOrders,
    required this.changeRequests,
    required this.historyByWorkOrder,
    required this.deletingIds,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const WorkOrdersState.initial()
    : workOrders = const [],
      changeRequests = const [],
      historyByWorkOrder = const <String, List<WorkOrderHistoryEntity>>{},
      deletingIds = const <String>{},
      super(status: StateStatus.initial, errorMessage: '');

  final List<WorkOrderEntity> workOrders;
  final List<WorkOrderChangeRequestEntity> changeRequests;
  final Map<String, List<WorkOrderHistoryEntity>> historyByWorkOrder;
  final Set<String> deletingIds;

  WorkOrdersState copyWith({
    List<WorkOrderEntity>? workOrders,
    List<WorkOrderChangeRequestEntity>? changeRequests,
    Map<String, List<WorkOrderHistoryEntity>>? historyByWorkOrder,
    Set<String>? deletingIds,
    StateStatus? status,
    String? errorMessage,
    bool? annulErrorMessage,
  }) {
    return WorkOrdersState(
      workOrders: workOrders ?? this.workOrders,
      changeRequests: changeRequests ?? this.changeRequests,
      historyByWorkOrder: historyByWorkOrder ?? this.historyByWorkOrder,
      deletingIds: deletingIds ?? this.deletingIds,
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
    deletingIds,
    status,
    errorMessage,
  ];
}
