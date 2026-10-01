import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/cubits/assets/assets_cubit.dart';
import 'package:o_jogo_da_obra/features/customers/presentation/cubits/customers/customers_cubit.dart';
import 'package:o_jogo_da_obra/features/locations/presentation/cubits/locations/locations_cubit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_step.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/prerequisite/prerequisite_type.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class PrerequisiteGuideCard extends StatelessWidget {
  const PrerequisiteGuideCard({
    super.key,
    required this.steps,
    this.title,
    this.subtitle,
    this.onAction,
  });

  final List<PrerequisiteStep> steps;
  final String? title;
  final String? subtitle;
  final void Function(PrerequisiteType type)? onAction;

  void _handleStepAction(BuildContext context, PrerequisiteStep step) {
    if (onAction != null) {
      onAction!(step.type);
      return;
    }

    switch (step.type) {
      case PrerequisiteType.location:
        try {
          context.read<LocationsCubit>().navigateToCreateUpdateLocation();
        } catch (_) {}
      case PrerequisiteType.area:
        try {
          final locs = context.read<LocationsCubit>().state.locations;
          if (locs.isNotEmpty) {
            context.read<LocationsCubit>().navigateToCreateUpdateArea(
              locationId: locs.first.id,
            );
          } else {
            context.read<LocationsCubit>().navigateToCreateUpdateLocation();
          }
        } catch (_) {}
      case PrerequisiteType.customer:
        try {
          context.read<CustomersCubit>().navigateToCreateUpdateCustomer();
        } catch (_) {}
      case PrerequisiteType.asset:
        try {
          context.read<AssetsCubit>().navigateToCreateUpdateAsset();
        } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextPending = steps.cast<PrerequisiteStep?>().firstWhere(
      (s) => s?.isCompleted == false,
      orElse: () => null,
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(Sizes.p16),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(Sizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Sizes.p8),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: PlatformIcon(
                      materialIcon: Icons.checklist_rtl_rounded,
                      cupertinoIcon: CupertinoIcons.list_bullet,
                      color: context.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaseText.titleMedium(
                          title ?? 'Primeiros passos para começar'.hardcoded,
                          fontWeight: FontWeight.bold,
                        ),
                        gapH4,
                        BaseText.bodySmall(
                          subtitle ??
                              'Complete os cadastros abaixo para criar ordens de serviço:'
                                  .hardcoded,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              gapH20,
              const Divider(height: 1),
              gapH16,
              for (int i = 0; i < steps.length; i++) ...[
                _buildStepTile(
                  context: context,
                  step: steps[i],
                  index: i + 1,
                  isHighlighted: steps[i] == nextPending,
                ),
                if (i < steps.length - 1) gapH12,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required BuildContext context,
    required PrerequisiteStep step,
    required int index,
    required bool isHighlighted,
  }) {
    final isDone = step.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(Sizes.p12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? context.colorScheme.primaryContainer.withValues(alpha: 0.25)
            : isDone
            ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Sizes.p12),
        border: Border.all(
          color: isHighlighted
              ? context.colorScheme.primary.withValues(alpha: 0.5)
              : context.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? Colors.green
                  : isHighlighted
                  ? context.colorScheme.primary
                  : context.colorScheme.outlineVariant,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : BaseText(
                      '$index',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BaseText.bodyMedium(
                        step.title,
                        fontWeight: isHighlighted
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isDone
                            ? context.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              )
                            : context.colorScheme.onSurface,
                      ),
                    ),
                    if (step.isOptional)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.p8,
                          vertical: Sizes.p4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(Sizes.p4),
                        ),
                        child: BaseText.caption(
                          'Opcional'.hardcoded,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                gapH4,
                BaseText.bodySmall(
                  step.description,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                if (!isDone && isHighlighted) ...[
                  gapH12,
                  if (step.canPerformAction)
                    BaseButton(
                      key: ValueKey('PrerequisiteAction_${step.type.name}'),
                      text: step.actionLabel,
                      height: 36,
                      onTap: () => _handleStepAction(context, step),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.p8,
                        vertical: Sizes.p4,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.errorContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(Sizes.p8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: context.colorScheme.error,
                          ),
                          gapW8,
                          BaseText.bodySmall(
                            'Aguardando administrador cadastrar'.hardcoded,
                            color: context.colorScheme.error,
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
