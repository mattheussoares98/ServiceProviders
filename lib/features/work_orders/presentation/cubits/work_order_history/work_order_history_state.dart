part of 'work_order_history_cubit.dart';

class WorkOrderHistoryState extends BaseState {
  const WorkOrderHistoryState({
    this.history = const [],
    this.filteredHistory = const [],
    this.startDate,
    this.endDate,
    this.searchQuery,
    super.sections = const {},
  });

  const WorkOrderHistoryState.initial()
    : history = const [],
      filteredHistory = const [],
      startDate = null,
      endDate = null,
      searchQuery = null,
      super();

  final List<AuditLogEntity> history;
  final List<AuditLogEntity> filteredHistory;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  WorkOrderHistoryState copyWith({
    List<AuditLogEntity>? history,
    List<AuditLogEntity>? filteredHistory,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    bool annulStartDate = false,
    bool annulEndDate = false,
    bool annulSearchQuery = false,
    Map<SectionKey, SectionState>? sections,
  }) {
    return WorkOrderHistoryState(
      history: history ?? this.history,
      filteredHistory: filteredHistory ?? this.filteredHistory,
      startDate: annulStartDate ? null : startDate ?? this.startDate,
      endDate: annulEndDate ? null : endDate ?? this.endDate,
      searchQuery: annulSearchQuery ? null : searchQuery ?? this.searchQuery,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    history,
    filteredHistory,
    startDate,
    endDate,
    searchQuery,
    sections,
  ];
}
