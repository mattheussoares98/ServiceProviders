import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_kpi_metrics_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/kpi_period.dart';

class CalculateWorkOrderKpisParams extends Equatable {
  const CalculateWorkOrderKpisParams({
    required this.workOrders,
    this.period = KpiPeriod.allTime,
    this.referenceDate,
  });

  final List<WorkOrderEntity> workOrders;
  final KpiPeriod period;
  final DateTime? referenceDate;

  @override
  List<Object?> get props => [workOrders, period, referenceDate];
}

@LazySingleton()
class CalculateWorkOrderKpisUseCase
    implements
        UseCaseSynchronous<
          WorkOrderKpiMetricsEntity,
          CalculateWorkOrderKpisParams
        > {
  const CalculateWorkOrderKpisUseCase();

  @override
  WorkOrderKpiMetricsEntity call(CalculateWorkOrderKpisParams request) {
    final now = request.referenceDate ?? DateTime.now();

    final scopedOrders = request.workOrders.where((wo) {
      if (wo.deletedAt != null) return false;
      final targetDate = wo.completedAt ?? wo.createdAt;
      return request.period.isWithinPeriod(targetDate, now);
    }).toList();

    if (scopedOrders.isEmpty) {
      return const WorkOrderKpiMetricsEntity.empty();
    }

    final openCount = scopedOrders
        .where((wo) => wo.status == WorkOrderStatus.open)
        .length;
    final inProgressCount = scopedOrders
        .where((wo) => wo.status == WorkOrderStatus.inProgress)
        .length;
    final pendingApprovalCount = scopedOrders
        .where((wo) => wo.status == WorkOrderStatus.pendingConclusionApproval)
        .length;

    final delayedCount = scopedOrders.where((wo) {
      final isClosed =
          wo.status == WorkOrderStatus.completed ||
          wo.status == WorkOrderStatus.cancelled;
      if (isClosed) return false;
      final deadline = wo.slaDeadlineAt;
      return deadline != null && deadline.isBefore(now);
    }).length;

    final completedOrders = scopedOrders
        .where((wo) => wo.status == WorkOrderStatus.completed)
        .toList();
    final completedCount = completedOrders.length;

    var completedWithinSlaCount = 0;
    var slaBreachedCount = 0;
    var totalDurationMinutes = 0.0;
    var validDurationCount = 0;

    for (final wo in completedOrders) {
      final isBreached =
          wo.slaBreached ||
          (wo.slaDeadlineAt != null &&
              wo.completedAt != null &&
              wo.completedAt!.isAfter(wo.slaDeadlineAt!));

      if (isBreached) {
        slaBreachedCount++;
      } else {
        completedWithinSlaCount++;
      }

      double? duration;
      if (wo.netActiveDuration != null && wo.netActiveDuration! > 0) {
        duration = wo.netActiveDuration!.toDouble();
      } else if (wo.completedAt != null && wo.startedAt != null) {
        final diff = wo.completedAt!.difference(wo.startedAt!).inMinutes;
        if (diff >= 0) {
          duration = diff.toDouble();
        }
      } else if (wo.actualDuration != null && wo.actualDuration! > 0) {
        duration = wo.actualDuration!.toDouble();
      }

      if (duration != null) {
        totalDurationMinutes += duration;
        validDurationCount++;
      }
    }

    final deliveryRate = completedCount > 0
        ? (completedWithinSlaCount / completedCount) * 100.0
        : 0.0;

    final breachRate = completedCount > 0
        ? (slaBreachedCount / completedCount) * 100.0
        : 0.0;

    final mttrMinutes = validDurationCount > 0
        ? totalDurationMinutes / validDurationCount
        : 0.0;

    return WorkOrderKpiMetricsEntity(
      totalWorkOrders: scopedOrders.length,
      completedCount: completedCount,
      completedWithinSlaCount: completedWithinSlaCount,
      slaBreachedCount: slaBreachedCount,
      deliveryRate: deliveryRate,
      breachRate: breachRate,
      mttrMinutes: mttrMinutes,
      openCount: openCount,
      inProgressCount: inProgressCount,
      delayedCount: delayedCount,
      pendingApprovalCount: pendingApprovalCount,
    );
  }
}
