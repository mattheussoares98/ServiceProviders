part of 'escalation_parameters_card.dart';

class _EscalationHierarchyList extends StatelessWidget {
  const _EscalationHierarchyList({
    required this.escalationGroupIds,
    required this.availableGroups,
    required this.delayedIntervalController,
    required this.permissionGroups,
    required this.isAdmin,
    required this.onAddGroup,
    required this.onRemoveGroup,
    required this.onReorder,
  });

  final List<String> escalationGroupIds;
  final List<PermissionGroupEntity> availableGroups;
  final TextEditingController delayedIntervalController;
  final List<PermissionGroupEntity> permissionGroups;
  final bool isAdmin;
  final ValueChanged<String> onAddGroup;
  final ValueChanged<String> onRemoveGroup;
  final ReorderCallback onReorder;

  String _getGroupName(String id) {
    for (final g in permissionGroups) {
      if (g.id == id) return g.name;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final intervalMinutes = int.tryParse(delayedIntervalController.text) ?? 30;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: BaseText.bodySmall(
                'Ordem de escalonamento (níveis sucessivos):'.hardcoded,
              ),
            ),
            if (isAdmin && availableGroups.isNotEmpty)
              PopupMenuButton<String>(
                tooltip: 'Adicionar grupo ao escalonamento'.hardcoded,
                icon: const PlatformIcon(
                  materialIcon: Icons.add_circle_outline,
                  cupertinoIcon: CupertinoIcons.add_circled,
                ),
                onSelected: onAddGroup,
                itemBuilder: (context) => availableGroups
                    .map(
                      (g) =>
                          PopupMenuItem(value: g.id, child: BaseText(g.name)),
                    )
                    .toList(),
              ),
          ],
        ),
        gapH8,
        if (escalationGroupIds.isEmpty)
          Container(
            padding: const EdgeInsets.all(Sizes.p12),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(Sizes.p8),
            ),
            child: Center(
              child: BaseText.bodySmall(
                'Nenhum grupo adicional na cadeia de escalonamento. Apenas o responsável receberá os alertas de atraso.'
                    .hardcoded,
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: escalationGroupIds.length,
            onReorderItem: isAdmin ? onReorder : null,
            itemBuilder: (context, index) {
              final groupId = escalationGroupIds[index];
              final groupName = _getGroupName(groupId);
              return Container(
                key: ValueKey(groupId),
                margin: const EdgeInsets.only(bottom: Sizes.p4),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(Sizes.p8),
                  border: Border.all(
                    color: context.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Padding(
                    padding: const .all(Sizes.p8),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: context.colorScheme.primaryContainer,
                      child: BaseText.bodySmall(
                        '${index + 1}',
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: BaseText.bodyMedium(groupName),
                  subtitle: BaseText.bodySmall(
                    'Nível ${index + 1}: acionado após ${(index + 1) * intervalMinutes} min de atraso'
                        .hardcoded,
                  ),
                  trailing: isAdmin
                      ? Padding(
                          padding: const EdgeInsets.only(right: Sizes.p24),
                          child: BaseIconButton(
                            platformIcon: const PlatformIcon(
                              materialIcon: Icons.delete_outline,
                              cupertinoIcon: CupertinoIcons.trash,
                              color: Colors.red,
                            ),
                            onPressed: () => onRemoveGroup(groupId),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }
}
