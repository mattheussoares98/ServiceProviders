import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/work_order_history/work_order_history_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/secondary_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class HistoryDateFilterBar extends StatelessWidget {
  const HistoryDateFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final startDate = context.select<WorkOrderHistoryCubit, DateTime?>(
      (cubit) => cubit.state.startDate,
    );
    final endDate = context.select<WorkOrderHistoryCubit, DateTime?>(
      (cubit) => cubit.state.endDate,
    );
    final hasFilter = startDate != null || endDate != null;

    Future<void> pickDateRange() async {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(now.year + 2),
        initialDateRange: startDate != null && endDate != null
            ? DateTimeRange(start: startDate, end: endDate)
            : null,
      );

      if (picked != null && context.mounted) {
        context.read<WorkOrderHistoryCubit>().setDateRange(
          startDate: picked.start,
          endDate: picked.end,
        );
      }
    }

    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            onTap: pickDateRange,
            text: hasFilter
                ? '${startDate?.formatDate() ?? ''} - ${endDate?.formatDate() ?? ''}'
                : 'Filtrar por período'.hardcoded,
            platformIcon: const PlatformIcon(
              materialIcon: Icons.date_range,
              cupertinoIcon: Icons.date_range,
            ),
          ),
        ),
        if (hasFilter) ...[
          gapW8,
          BaseIconButton(
            onPressed: () =>
                context.read<WorkOrderHistoryCubit>().clearDateFilter(),
            platformIcon: const PlatformIcon(
              materialIcon: Icons.clear,
              cupertinoIcon: Icons.clear,
            ),
          ),
        ],
      ],
    );
  }
}
