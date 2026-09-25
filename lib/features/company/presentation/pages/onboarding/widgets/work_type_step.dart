import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/onboarding/onboarding_cubit.dart';
import 'package:o_jogo_da_obra/features/company/presentation/extensions/work_type_ui_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class WorkTypeStep extends StatelessWidget {
  const WorkTypeStep({
    super.key,
    required this.cubit,
    required this.selectedWorkType,
  });

  final OnboardingCubit cubit;
  final WorkType selectedWorkType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BaseText.title('Modelo de atuação'.hardcoded),
        gapH8,
        BaseText(
          'Selecione como sua empresa opera para personalizarmos sua experiência.'.hardcoded,
        ),
        gapH32,
        ...WorkType.values.map(
          (type) => Padding(
            padding: const EdgeInsets.only(bottom: Sizes.p16),
            child: _WorkTypeCard(
              title: type.label,
              description: type.description,
              platformIcon: type.platformIcon,
              isSelected: selectedWorkType == type,
              onTap: () => cubit.selectWorkType(type),
            ),
          ),
        ),
        gapH16,
        Row(
          children: [
            Expanded(
              child: BaseButton.secondary(
                expandWidth: true,
                text: 'VOLTAR'.hardcoded,
                onTap: cubit.previousStep,
              ),
            ),
            gapW16,
            Expanded(
              child: BaseButton(
                expandWidth: true,
                text: 'CONTINUAR'.hardcoded,
                onTap: cubit.nextStep,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WorkTypeCard extends StatelessWidget {
  const _WorkTypeCard({
    required this.title,
    required this.description,
    required this.platformIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final PlatformIcon platformIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.theme.colorScheme.primary;
    final cardColor = context.theme.cardColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(Sizes.p16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : context.theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(Sizes.p12),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : context.theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: platformIcon.copyWith(
                color: isSelected ? Colors.white : primaryColor,
              ),
            ),
            gapW16,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaseText.title(
                    title,
                    color: isSelected
                        ? primaryColor
                        : context.theme.colorScheme.onSurface,
                  ),
                  gapH4,
                  BaseText(
                    description,
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.65,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
