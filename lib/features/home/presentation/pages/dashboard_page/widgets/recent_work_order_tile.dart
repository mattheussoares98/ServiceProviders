import 'package:clean_architecture/core/utils/extensions/date_time_extension.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/presentation/extensions/work_order_extensions.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:clean_architecture/shared_ui/utils/extensions/build_context_extension.dart';
import 'package:flutter/material.dart';

class RecentWorkOrderTile extends StatelessWidget {
  const RecentWorkOrderTile({
    super.key,
    required this.workOrder,
    required this.onTap,
  });

  final WorkOrderEntity workOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      margin: const EdgeInsets.only(bottom: Sizes.p8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.p12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Sizes.p12),
        child: Padding(
          padding: const EdgeInsets.all(Sizes.p12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      workOrder.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p4,
                    ),
                    decoration: BoxDecoration(
                      color: workOrder.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Sizes.p4),
                    ),
                    child: Text(
                      workOrder.status.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: workOrder.status.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              gapH8,
              if (workOrder.description != null &&
                  workOrder.description!.isNotEmpty) ...[
                Text(
                  workOrder.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                gapH8,
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Sizes.p8,
                      vertical: Sizes.p4,
                    ),
                    decoration: BoxDecoration(
                      color: workOrder.priority.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Sizes.p4),
                    ),
                    child: Text(
                      'Prioridade: ${workOrder.priority.label}'.hardcoded,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: workOrder.priority.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    workOrder.createdAt.formattedBrazilianDate(
                      includeTime: true,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
