part of 'access_logs_cubit.dart';

class AccessLogsState extends BaseState {
  const AccessLogsState({
    this.logs = const [],
    this.users = const [],
    this.startDate,
    this.endDate,
    this.selectedUserId,
    this.hasReachedMax = false,
    this.page = 0,
    super.sections = const {},
  });

  const AccessLogsState.initial()
    : logs = const [],
      users = const [],
      startDate = null,
      endDate = null,
      selectedUserId = null,
      hasReachedMax = false,
      page = 0,
      super();

  final List<AccessLogEntity> logs;
  final List<UserProfileEntity> users;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedUserId;
  final bool hasReachedMax;
  final int page;

  AccessLogsState copyWith({
    List<AccessLogEntity>? logs,
    List<UserProfileEntity>? users,
    DateTime? startDate,
    DateTime? endDate,
    String? selectedUserId,
    bool? hasReachedMax,
    int? page,
    bool annulStartDate = false,
    bool annulEndDate = false,
    bool annulSelectedUserId = false,
    Map<SectionKey, SectionState>? sections,
  }) {
    return AccessLogsState(
      logs: logs ?? this.logs,
      users: users ?? this.users,
      startDate: annulStartDate ? null : startDate ?? this.startDate,
      endDate: annulEndDate ? null : endDate ?? this.endDate,
      selectedUserId:
          annulSelectedUserId ? null : selectedUserId ?? this.selectedUserId,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      sections: sections ?? this.sections,
    );
  }

  @override
  List<Object?> get props => [
    logs,
    users,
    startDate,
    endDate,
    selectedUserId,
    hasReachedMax,
    page,
    sections,
  ];
}
