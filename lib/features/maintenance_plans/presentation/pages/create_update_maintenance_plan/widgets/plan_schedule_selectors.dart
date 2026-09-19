import 'package:flutter/material.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/presentation/extensions/interval_unit_ui_extension.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_switch.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/number_validator.dart';

class PlanScheduleSelectors extends StatelessWidget {
  const PlanScheduleSelectors({
    super.key,
    required this.intervalValueController,
    required this.leadTimeDaysController,
    required this.durationDaysController,
    required this.intervalValFocusNode,
    required this.leadTimeFocusNode,
    required this.durationFocusNode,
    required this.selectedIntervalUnit,
    required this.isActive,
    required this.onIntervalUnitChanged,
    required this.onIsActiveChanged,
  });

  final TextEditingController intervalValueController;
  final TextEditingController leadTimeDaysController;
  final TextEditingController durationDaysController;
  final FocusNode intervalValFocusNode;
  final FocusNode leadTimeFocusNode;
  final FocusNode durationFocusNode;
  final IntervalUnit selectedIntervalUnit;
  final bool isActive;
  final ValueChanged<IntervalUnit?> onIntervalUnitChanged;
  final ValueChanged<bool> onIsActiveChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: .end,
          children: [
            Expanded(
              flex: 2,
              child: BaseTextFormField(
                labelText: 'A cada *'.hardcoded,
                hintText: '1'.hardcoded,
                controller: intervalValueController,
                focusNode: intervalValFocusNode,
                keyboardType: TextInputType.number,
                validator: FormValidators.compose([
                  NonEmptyValidator(),
                  NumberValidator(allowDecimal: false),
                ]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            gapW16,
            Expanded(
              flex: 3,
              child: Align(
                alignment: .bottomCenter,
                child: BaseDropDown<IntervalUnit>(
                  key: const ValueKey('PlanIntervalUnit'),
                  showLabelAtTopLeft: true,
                  label: 'Unidade *'.hardcoded,
                  selectedItem: selectedIntervalUnit,
                  items: IntervalUnit.values
                      .map(
                        (u) => DropdownMenuItem(
                          value: u,
                          child: BaseText(u.label),
                        ),
                      )
                      .toList(),
                  onChanged: onIntervalUnitChanged,
                ),
              ),
            ),
          ],
        ),
        gapH16,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BaseTextFormField(
                labelText: 'Antecedência (dias) *'.hardcoded,
                hintText: '2'.hardcoded,
                controller: leadTimeDaysController,
                focusNode: leadTimeFocusNode,
                keyboardType: TextInputType.number,
                validator: FormValidators.compose([
                  NonEmptyValidator(),
                  NumberValidator(
                    allowDecimal: false,
                    needsBeGreaterThanZero: false,
                  ),
                ]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            gapW16,
            Expanded(
              child: BaseTextFormField(
                labelText: 'Duração estimada (dias) *'.hardcoded,
                hintText: '1'.hardcoded,
                controller: durationDaysController,
                focusNode: durationFocusNode,
                keyboardType: TextInputType.number,
                validator: FormValidators.compose([
                  NonEmptyValidator(),
                  NumberValidator(allowDecimal: false),
                ]),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
          ],
        ),
        gapH16,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BaseText.bodyMedium('Plano ativo'.hardcoded),
            BaseSwitch(value: isActive, onChanged: onIsActiveChanged),
          ],
        ),
      ],
    );
  }
}
