import 'package:equatable/equatable.dart';

class WorkOrderKpiMetricsEntity extends Equatable {
  const WorkOrderKpiMetricsEntity({
    required this.totalWorkOrders,
    required this.completedCount,
    required this.completedWithinSlaCount,
    required this.slaBreachedCount,
    required this.deliveryRate,
    required this.breachRate,
    required this.mttrMinutes,
    required this.openCount,
    required this.inProgressCount,
    required this.delayedCount,
    required this.pendingApprovalCount,
  });

  const WorkOrderKpiMetricsEntity.empty()
    : totalWorkOrders = 0,
      completedCount = 0,
      completedWithinSlaCount = 0,
      slaBreachedCount = 0,
      deliveryRate = 0.0,
      breachRate = 0.0,
      mttrMinutes = 0.0,
      openCount = 0,
      inProgressCount = 0,
      delayedCount = 0,
      pendingApprovalCount = 0;

  final int totalWorkOrders;
  final int completedCount;
  final int completedWithinSlaCount;
  final int slaBreachedCount;
  final double deliveryRate;
  final double breachRate;
  final double mttrMinutes;
  final int openCount;
  final int inProgressCount;
  final int delayedCount;
  final int pendingApprovalCount;

  WorkOrderKpiMetricsEntity copyWith({
    int? totalWorkOrders,
    int? completedCount,
    int? completedWithinSlaCount,
    int? slaBreachedCount,
    double? deliveryRate,
    double? breachRate,
    double? mttrMinutes,
    int? openCount,
    int? inProgressCount,
    int? delayedCount,
    int? pendingApprovalCount,
  }) {
    return WorkOrderKpiMetricsEntity(
      totalWorkOrders: totalWorkOrders ?? this.totalWorkOrders,
      completedCount: completedCount ?? this.completedCount,
      completedWithinSlaCount:
          completedWithinSlaCount ?? this.completedWithinSlaCount,
      slaBreachedCount: slaBreachedCount ?? this.slaBreachedCount,
      deliveryRate: deliveryRate ?? this.deliveryRate,
      breachRate: breachRate ?? this.breachRate,
      mttrMinutes: mttrMinutes ?? this.mttrMinutes,
      openCount: openCount ?? this.openCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      delayedCount: delayedCount ?? this.delayedCount,
      pendingApprovalCount:
          pendingApprovalCount ?? this.pendingApprovalCount,
    );
  }

  @override
  List<Object?> get props => [
    totalWorkOrders,
    completedCount,
    completedWithinSlaCount,
    slaBreachedCount,
    deliveryRate,
    breachRate,
    mttrMinutes,
    openCount,
    inProgressCount,
    delayedCount,
    pendingApprovalCount,
  ];
}
