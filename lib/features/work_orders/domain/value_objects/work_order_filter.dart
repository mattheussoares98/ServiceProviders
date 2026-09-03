import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

class WorkOrderFilter extends Equatable {
  const WorkOrderFilter({
    this.statuses = const [],
    this.priorities = const [],
    this.type,
    this.assignedToId,
    this.scheduledDateFrom,
    this.scheduledDateTo,
    this.searchText,
    this.serviceProviderCompanyIds = const [],
    this.isDelayed = false,
    this.onlyDeleted = false,
  });

  final List<WorkOrderStatus> statuses;
  final List<Priority> priorities;
  final WorkOrderType? type;
  final String? assignedToId;
  final DateTime? scheduledDateFrom;
  final DateTime? scheduledDateTo;
  final String? searchText;

  /// Provider mode only. Restricts results to work orders assigned to these
  /// provider companies. Empty means every company the provider belongs to.
  final List<String> serviceProviderCompanyIds;

  /// Filter to retrieve only active work orders that are overdue/delayed.
  final bool isDelayed;

  /// Filter to retrieve only soft-deleted work orders.
  final bool onlyDeleted;

  bool get isEmpty =>
      statuses.isEmpty &&
      priorities.isEmpty &&
      type == null &&
      assignedToId == null &&
      scheduledDateFrom == null &&
      scheduledDateTo == null &&
      (searchText == null || searchText!.isEmpty) &&
      serviceProviderCompanyIds.isEmpty &&
      !isDelayed &&
      !onlyDeleted;

  int get activeCount {
    var count = 0;
    if (statuses.isNotEmpty) count++;
    if (priorities.isNotEmpty) count++;
    if (type != null) count++;
    if (assignedToId != null) count++;
    if (scheduledDateFrom != null || scheduledDateTo != null) count++;
    if (searchText != null && searchText!.isNotEmpty) count++;
    if (serviceProviderCompanyIds.isNotEmpty) count++;
    if (isDelayed) count++;
    if (onlyDeleted) count++;
    return count;
  }

  WorkOrderFilter copyWith({
    List<WorkOrderStatus>? statuses,
    List<Priority>? priorities,
    WorkOrderType? type,
    String? assignedToId,
    DateTime? scheduledDateFrom,
    DateTime? scheduledDateTo,
    String? searchText,
    List<String>? serviceProviderCompanyIds,
    bool? isDelayed,
    bool? onlyDeleted,
    bool annulType = false,
    bool annulAssignedToId = false,
    bool annulScheduledDateFrom = false,
    bool annulScheduledDateTo = false,
    bool annulSearchText = false,
  }) {
    return WorkOrderFilter(
      statuses: statuses ?? this.statuses,
      priorities: priorities ?? this.priorities,
      type: annulType ? null : type ?? this.type,
      assignedToId:
          annulAssignedToId ? null : assignedToId ?? this.assignedToId,
      scheduledDateFrom: annulScheduledDateFrom
          ? null
          : scheduledDateFrom ?? this.scheduledDateFrom,
      scheduledDateTo: annulScheduledDateTo
          ? null
          : scheduledDateTo ?? this.scheduledDateTo,
      searchText:
          annulSearchText ? null : searchText ?? this.searchText,
      serviceProviderCompanyIds:
          serviceProviderCompanyIds ?? this.serviceProviderCompanyIds,
      isDelayed: isDelayed ?? this.isDelayed,
      onlyDeleted: onlyDeleted ?? this.onlyDeleted,
    );
  }

  @override
  List<Object?> get props => [
    statuses,
    priorities,
    type,
    assignedToId,
    scheduledDateFrom,
    scheduledDateTo,
    searchText,
    serviceProviderCompanyIds,
    isDelayed,
    onlyDeleted,
  ];
}
