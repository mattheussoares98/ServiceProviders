part of 'work_orders_cubit.dart';

enum WorkOrdersSections implements SectionKey { saveWorkOrder }

class WorkOrdersState extends BaseState {
  const WorkOrdersState({
    required this.workOrders,
    required this.changeRequests,
    this.activeFilter = const WorkOrderFilter(),
    this.hasMorePages = true,
    this.isLoadingMore = false,
    this.providerCompanies = const [],
    super.sections = const {},
  });

  const WorkOrdersState.initial()
    : workOrders = const [],
      changeRequests = const [],
      activeFilter = const WorkOrderFilter(),
      hasMorePages = true,
      isLoadingMore = false,
      providerCompanies = const [],
      super();

  final List<WorkOrderEntity> workOrders;
  final List<WorkOrderChangeRequestEntity> changeRequests;
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
    WorkOrderFilter? activeFilter,
    bool? hasMorePages,
    bool? isLoadingMore,
    List<ServiceProviderCompanyEntity>? providerCompanies,
    Map<SectionKey, SectionState>? sections,
  }) {
    return WorkOrdersState(
      workOrders: workOrders ?? this.workOrders,
      changeRequests: changeRequests ?? this.changeRequests,
      activeFilter: activeFilter ?? this.activeFilter,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      providerCompanies: providerCompanies ?? this.providerCompanies,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    workOrders,
    changeRequests,
    activeFilter,
    hasMorePages,
    isLoadingMore,
    providerCompanies,
    sections,
  ];
}
