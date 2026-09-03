part of 'work_order_details_cubit.dart';

enum WorkOrderDetailsSections implements SectionKey {
  changeStatus,
  resumeWork,
  deleteWorkOrder,
  restoreWorkOrder,
  createChangeRequest,
  reviewChangeRequest,
}

class WorkOrderDetailsState extends BaseState {
  const WorkOrderDetailsState({
    this.workOrder,
    this.history = const [],
    super.sections = const {},
  });

  const WorkOrderDetailsState.initial()
    : workOrder = null,
      history = const [],
      super();

  final WorkOrderEntity? workOrder;
  final List<WorkOrderHistoryEntity> history;

  WorkOrderDetailsState copyWith({
    WorkOrderEntity? workOrder,
    bool annulWorkOrder = false,
    List<WorkOrderHistoryEntity>? history,
    Map<SectionKey, SectionState>? sections,
  }) {
    return WorkOrderDetailsState(
      workOrder: annulWorkOrder ? null : workOrder ?? this.workOrder,
      history: history ?? this.history,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [workOrder, history, sections];
}
