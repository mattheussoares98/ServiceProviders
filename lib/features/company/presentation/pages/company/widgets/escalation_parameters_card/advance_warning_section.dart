part of 'escalation_parameters_card.dart';

class _AdvanceWarningSection extends StatelessWidget {
  const _AdvanceWarningSection({
    required this.advanceMinutesController,
    required this.focusNode,
    required this.advanceGroupIds,
    required this.permissionGroups,
    required this.isAdmin,
    required this.onToggleAdvanceGroup,
  });

  final TextEditingController advanceMinutesController;
  final FocusNode focusNode;
  final List<String> advanceGroupIds;
  final List<PermissionGroupEntity> permissionGroups;
  final bool isAdmin;
  final ValueChanged<String> onToggleAdvanceGroup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const PlatformIcon(
              materialIcon: Icons.timer_outlined,
              cupertinoIcon: CupertinoIcons.timer,
            ),
            gapW8,
            Expanded(
              child: BaseText.title('Aviso prévio de vencimento'.hardcoded),
            ),
          ],
        ),
        gapH4,
        BaseText.bodySmall(
          'Tempo de antecedência antes do prazo limite do SLA. O usuário responsável é sempre notificado.'
              .hardcoded,
        ),
        gapH8,
        BaseTextFormField(
          controller: advanceMinutesController,
          focusNode: focusNode,
          enabled: isAdmin,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          labelText: 'Minutos de antecedência'.hardcoded,
          suffixText: 'minutos'.hardcoded,
        ),
        gapH12,
        BaseText.bodySmall('Grupos notificados no aviso prévio:'.hardcoded),
        gapH8,
        if (permissionGroups.isEmpty)
          BaseText.bodySmall('Nenhum grupo de permissão disponível.'.hardcoded)
        else
          Wrap(
            spacing: Sizes.p8,
            runSpacing: Sizes.p4,
            children: permissionGroups.map((group) {
              final isSelected = advanceGroupIds.contains(group.id);
              return FilterChip(
                label: BaseText(group.name),
                selected: isSelected,
                onSelected: isAdmin
                    ? (_) => onToggleAdvanceGroup(group.id)
                    : null,
              );
            }).toList(),
          ),
      ],
    );
  }
}
