import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/onboarding/onboarding_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/extensions/work_type_ui_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class ConfirmationStep extends StatelessWidget {
  const ConfirmationStep({
    super.key,
    required this.cubit,
    required this.companyName,
    required this.cnpj,
    required this.workType,
    required this.isLoading,
  });

  final OnboardingCubit cubit;
  final String companyName;
  final String cnpj;
  final WorkType workType;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.theme.cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseText.title('Confirmação'.hardcoded),
        gapH8,
        BaseText(
          'Revise os dados antes de finalizar o cadastro da sua empresa.'
              .hardcoded,
        ),
        gapH32,
        Container(
          padding: const EdgeInsets.all(Sizes.p20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BaseText(
                'Nome da empresa'.hardcoded,
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
              gapH4,
              BaseText.title(companyName),
              gapH16,
              if (cnpj.isNotEmpty) ...[
                BaseText(
                  (cnpj.length <= 11 ? 'CPF' : 'CNPJ').hardcoded,
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
                gapH4,
                BaseText(cnpj),
                gapH16,
              ],
              BaseText(
                'Modelo de atuação'.hardcoded,
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
              gapH4,
              Row(
                children: [
                  workType.platformIcon.copyWith(
                    color: context.theme.colorScheme.primary,
                  ),
                  gapW8,
                  Expanded(
                    child: BaseText(
                      '${workType.label} - ${workType.description}',
                    ),
                  ),
                ],
              ),
              gapH16,
              BaseText(
                'Plano inicial'.hardcoded,
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
              gapH4,
              BaseText('Gratuito ✅'.hardcoded),
            ],
          ),
        ),
        gapH32,
        Row(
          children: [
            Expanded(
              child: BaseButton.secondary(
                expandWidth: true,
                isLoading: isLoading,
                text: 'VOLTAR'.hardcoded,
                onTap: cubit.previousStep,
              ),
            ),
            gapW16,
            Expanded(
              child: BaseButton(
                expandWidth: true,
                isLoading: isLoading,
                text: 'CRIAR EMPRESA'.hardcoded,
                onTap: cubit.submit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
