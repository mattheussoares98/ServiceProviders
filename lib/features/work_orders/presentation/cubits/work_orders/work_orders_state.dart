part of 'work_orders_cubit.dart';

enum WorkOrdersSections implements SectionKey {
  saveWorkOrder,
  deleteWorkOrder,
  changeStatus,
  resumeWork,
  createChangeRequest,
  reviewChangeRequest,
}

class WorkOrdersState extends BaseState {
  const WorkOrdersState({
    required this.workOrders,
    required this.changeRequests,
    required this.historyByWorkOrder,
    this.activeFilter = const WorkOrderFilter(),
    this.hasMorePages = true,
    this.isLoadingMore = false,
    this.providerCompanies = const [],
    super.status = DataStatus.initial,
    super.errorMessage = '',
    super.sections = const {},
  });

  const WorkOrdersState.initial()
    : workOrders = const [],
      changeRequests = const [],
      historyByWorkOrder = const <String, List<WorkOrderHistoryEntity>>{},
      activeFilter = const WorkOrderFilter(),
      hasMorePages = true,
      isLoadingMore = false,
      providerCompanies = const [],
      super(status: DataStatus.initial, errorMessage: '');

  final List<WorkOrderEntity> workOrders;
  final List<WorkOrderChangeRequestEntity> changeRequests;
  final Map<String, List<WorkOrderHistoryEntity>> historyByWorkOrder;
  final WorkOrderFilter activeFilter;
  final bool hasMorePages;
  final bool isLoadingMore;

  /// Provider mode only. The provider companies the signed-in user belongs to.
  /// The company filter is offered only when this holds more than one entry.
  final List<ServiceProviderCompanyEntity> providerCompanies;

  /// Provider mode only. Null means "Todas as empresas".
  String? get selectedProviderCompanyId =>
      activeFilter.serviceProviderCompanyIds.length == 1
      ? activeFilter.serviceProviderCompanyIds.first
      : null;

  WorkOrdersState copyWith({
    List<WorkOrderEntity>? workOrders,
    List<WorkOrderChangeRequestEntity>? changeRequests,
    Map<String, List<WorkOrderHistoryEntity>>? historyByWorkOrder,
    WorkOrderFilter? activeFilter,
    bool? hasMorePages,
    bool? isLoadingMore,
    List<ServiceProviderCompanyEntity>? providerCompanies,
    Map<SectionKey, SectionStatus>? sections,
    DataStatus? status,
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
      providerCompanies: providerCompanies ?? this.providerCompanies,
      sections: sections ?? this.sections,
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
    providerCompanies,
    sections,
    status,
    errorMessage,
  ];
}
