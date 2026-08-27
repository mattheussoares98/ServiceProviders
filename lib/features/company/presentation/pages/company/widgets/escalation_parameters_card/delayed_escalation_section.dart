part of 'escalation_parameters_card.dart';

class _DelayedEscalationSection extends StatelessWidget {
  const _DelayedEscalationSection({
    required this.delayedIntervalController,
    required this.focusNode,
    required this.isAdmin,
  });

  final TextEditingController delayedIntervalController;
  final FocusNode focusNode;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PlatformIcon(
              materialIcon: Icons.warning_amber_rounded,
              cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
            ),
            gapW8,
            Expanded(
              child: BaseText.title(
                'Escalonamento de ordens atrasadas'.hardcoded,
              ),
            ),
          ],
        ),
        gapH4,
        BaseText.bodySmall(
          'Intervalo para reaviso pós-vencimento. A cada intervalo, o próximo nível da hierarquia é acionado em cascata.'
              .hardcoded,
        ),
        gapH8,
        BaseTextFormField(
          controller: delayedIntervalController,
          focusNode: focusNode,
          enabled: isAdmin,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          labelText: 'Intervalo de reaviso após vencimento'.hardcoded,
          suffixText: 'minutos'.hardcoded,
        ),
      ],
    );
  }
}
