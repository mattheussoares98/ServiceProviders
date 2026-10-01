import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/extensions/work_type_ui_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/loading_circle.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class WorkTypeConfigurationCard extends StatelessWidget {
  const WorkTypeConfigurationCard({required this.company, super.key});

  final CompanyEntity company;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<SessionCubit, bool>(
      (cubit) => cubit.state.user.isAdmin,
    );
    final isUpdating = context.select<CompanyCubit, bool>(
      (cubit) => cubit.state.section(CompanySections.updateWorkType).isRunning,
    );

    return Card(
      margin: const EdgeInsets.only(top: Sizes.p16),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const PlatformIcon(
                  materialIcon: Icons.business_center_outlined,
                  cupertinoIcon: CupertinoIcons.briefcase,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.titleMedium('Modelo de operação'.hardcoded),
                      gapH4,
                      BaseText.bodySmall(
                        'Define o fluxo de trabalho da sua empresa (locais próprios, atendimento a clientes ou híbrido).'
                            .hardcoded,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
                if (isUpdating) LoadingCircle.small(),
              ],
            ),
            gapH16,
            const Divider(height: 1),
            gapH12,
            ...WorkType.values.map((type) {
              final isSelected = company.workType == type;
              final isAllowed = isSelected || company.canUpgradeTo(type);
              final isEnabled =
                  isAdmin && !isUpdating && isAllowed && !isSelected;

              return Opacity(
                opacity: isAllowed ? 1.0 : 0.38,
                child: InkWell(
                  key: ValueKey('WorkTypeOption_${type.code}'),
                  onTap: !isEnabled
                      ? null
                      : () async {
                          final companyCubit = context.read<CompanyCubit>();
                          final confirmed = await showAlertDialog(
                            context: context,
                            title: 'Alterar modelo de operação'.hardcoded,
                            contentText:
                                'Ao alterar o modelo para híbrido, a empresa passará a gerenciar locais próprios e clientes simultaneamente. Essa alteração não poderá ser desfeita para modelos exclusivos.'
                                    .hardcoded,
                            cancelActionText: 'Cancelar'.hardcoded,
                            defaultActionText: 'Confirmar'.hardcoded,
                          );
                          if (confirmed ?? false) {
                            await companyCubit.updateWorkType(type);
                          }
                        },
                  borderRadius: BorderRadius.circular(Sizes.p8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.p8,
                      horizontal: Sizes.p8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Sizes.p8),
                      color: isSelected
                          ? context.colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            )
                          : Colors.transparent,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        type.platformIcon,
                        gapW12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BaseText.bodyMedium(
                                type.label,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? context.colorScheme.primary
                                    : context.colorScheme.onSurface,
                              ),
                              gapH4,
                              BaseText.bodySmall(
                                type.description,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: Sizes.p4),
                          child: Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? context.colorScheme.primary
                                : (isAllowed
                                      ? context.colorScheme.outline
                                      : context.colorScheme.outlineVariant),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
