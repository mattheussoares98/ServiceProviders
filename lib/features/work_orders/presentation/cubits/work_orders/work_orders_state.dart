part of 'work_orders_cubit.dart';

class WorkOrdersState extends BaseState {
  const WorkOrdersState({
    required this.workOrders,
    required this.changeRequests,
    required this.historyByWorkOrder,
    super.status = StateStatus.initial,
    super.errorMessage = '',
  });

  const WorkOrdersState.initial()
    : workOrders = const [],
      changeRequests = const [],
      historyByWorkOrder = const <String, List<WorkOrderHistoryEntity>>{},
      super(status: StateStatus.initial, errorMessage: '');

  final List<WorkOrderEntity> workOrders;
  final List<WorkOrderChangeRequestEntity> changeRequests;
  final Map<String, List<WorkOrderHistoryEntity>> historyByWorkOrder;

  WorkOrdersState copyWith({
    List<WorkOrderEntity>? workOrders,
    List<WorkOrderChangeRequestEntity>? changeRequests,
    Map<String, List<WorkOrderHistoryEntity>>? historyByWorkOrder,
    StateStatus? status,
    String? errorMessage,
  }) {
    return WorkOrdersState(
      workOrders: workOrders ?? this.workOrders,
      changeRequests: changeRequests ?? this.changeRequests,
      historyByWorkOrder: historyByWorkOrder ?? this.historyByWorkOrder,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    workOrders,
    changeRequests,
    historyByWorkOrder,
    status,
    errorMessage,
  ];
}