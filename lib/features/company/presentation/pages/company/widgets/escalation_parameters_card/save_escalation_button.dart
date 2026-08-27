part of 'escalation_parameters_card.dart';

class _SaveEscalationButton extends StatelessWidget {
  const _SaveEscalationButton({
    required this.isSaving,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return BaseButton(
      onTap: isSaving ? null : onSave,
      isLoading: isSaving,
      text: 'Salvar parâmetros de escalonamento'.hardcoded,
      expandWidth: true,
    );
  }
}
