import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/kpi_period.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class KpiPeriodFilterSelector extends StatelessWidget {
  const KpiPeriodFilterSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodSelected,
  });

  final KpiPeriod selectedPeriod;
  final ValueChanged<KpiPeriod> onPeriodSelected;

  String _getPeriodLabel(KpiPeriod period) {
    switch (period) {
      case KpiPeriod.last7Days:
        return '7 dias'.hardcoded;
      case KpiPeriod.last30Days:
        return '30 dias'.hardcoded;
      case KpiPeriod.thisMonth:
        return 'Este mês'.hardcoded;
      case KpiPeriod.allTime:
        return 'Tudo'.hardcoded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: KpiPeriod.values.map((period) {
          final isSelected = period == selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: Sizes.p4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onPeriodSelected(period),
                borderRadius: BorderRadius.circular(Sizes.p12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.p12,
                    vertical: Sizes.p4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.theme.colorScheme.primary
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(Sizes.p12),
                    border: Border.all(
                      color: isSelected
                          ? context.theme.colorScheme.primary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08)),
                      width: 1,
                    ),
                  ),
                  child: BaseText.bodySmall(
                    _getPeriodLabel(period),
                    color: isSelected
                        ? context.theme.colorScheme.onPrimary
                        : context.theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
