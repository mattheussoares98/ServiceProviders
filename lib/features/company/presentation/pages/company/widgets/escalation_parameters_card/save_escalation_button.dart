part of 'escalation_parameters_card.dart';

class _SaveEscalationButton extends StatelessWidget {
  const _SaveEscalationButton({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isSaving = context.select<CompanyCubit, bool>(
      (cubit) =>
          cubit.state.sections[CompanySections.updateEscalationParameters] ==
          SectionStatus.running,
    );

    return BaseButton(
      onTap: isSaving ? null : onSave,
      isLoading: isSaving,
      text: 'Salvar parâmetros de escalonamento'.hardcoded,
      expandWidth: true,
    );
  }
}
