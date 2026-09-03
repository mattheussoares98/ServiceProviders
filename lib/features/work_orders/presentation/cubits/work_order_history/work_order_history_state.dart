part of 'work_order_history_cubit.dart';

class WorkOrderHistoryState extends BaseState {
  const WorkOrderHistoryState({
    this.history = const [],
    this.startDate,
    this.endDate,
    super.sections = const {},
  });

  const WorkOrderHistoryState.initial()
    : history = const [],
      startDate = null,
      endDate = null,
      super();

  final List<AuditLogEntity> history;
  final DateTime? startDate;
  final DateTime? endDate;

  List<AuditLogEntity> get filteredHistory {
    if (startDate == null && endDate == null) {
      return history;
    }

    return history.where((item) {
      final itemDate = item.createdAt;

      if (startDate != null && endDate != null) {
        final start = DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );
        final end = DateTime(
          endDate!.year,
          endDate!.month,
          endDate!.day,
          23,
          59,
          59,
          999,
        );
        return (itemDate.isAfter(start) || itemDate.isAtSameMomentAs(start)) &&
            (itemDate.isBefore(end) || itemDate.isAtSameMomentAs(end));
      }

      if (startDate != null) {
        final start = DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
        );
        return itemDate.isAfter(start) || itemDate.isAtSameMomentAs(start);
      }

      if (endDate != null) {
        final end = DateTime(
          endDate!.year,
          endDate!.month,
          endDate!.day,
          23,
          59,
          59,
          999,
        );
        return itemDate.isBefore(end) || itemDate.isAtSameMomentAs(end);
      }

      return true;
    }).toList();
  }

  WorkOrderHistoryState copyWith({
    List<AuditLogEntity>? history,
    DateTime? startDate,
    DateTime? endDate,
    bool annulStartDate = false,
    bool annulEndDate = false,
    Map<SectionKey, SectionState>? sections,
  }) {
    return WorkOrderHistoryState(
      history: history ?? this.history,
      startDate: annulStartDate ? null : startDate ?? this.startDate,
      endDate: annulEndDate ? null : endDate ?? this.endDate,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [history, startDate, endDate, sections];
}
