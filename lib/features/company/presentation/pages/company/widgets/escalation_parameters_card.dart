import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

class EscalationParametersCard extends StatefulWidget {
  const EscalationParametersCard({
    super.key,
    required this.parameters,
    required this.permissionGroups,
  });

  final CompanyParameterEntity parameters;
  final List<PermissionGroupEntity> permissionGroups;

  @override
  State<EscalationParametersCard> createState() =>
      _EscalationParametersCardState();
}

class _EscalationParametersCardState extends State<EscalationParametersCard> {
  late TextEditingController _advanceMinutesController;
  late TextEditingController _delayedIntervalController;
  late List<String> _advanceGroupIds;
  late List<String> _escalationGroupIds;

  @override
  void initState() {
    super.initState();
    _advanceMinutesController = TextEditingController(
      text: widget.parameters.advanceWarningMinutes.toString(),
    );
    _delayedIntervalController = TextEditingController(
      text: widget.parameters.delayedNotificationIntervalMinutes.toString(),
    );
    _advanceGroupIds = List.from(widget.parameters.advanceWarningGroupIds);
    _escalationGroupIds = List.from(widget.parameters.escalationGroupIds);
  }

  @override
  void didUpdateWidget(covariant EscalationParametersCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parameters != widget.parameters) {
      _advanceMinutesController.text =
          widget.parameters.advanceWarningMinutes.toString();
      _delayedIntervalController.text =
          widget.parameters.delayedNotificationIntervalMinutes.toString();
      _advanceGroupIds = List.from(widget.parameters.advanceWarningGroupIds);
      _escalationGroupIds = List.from(widget.parameters.escalationGroupIds);
    }
  }

  @override
  void dispose() {
    _advanceMinutesController.dispose();
    _delayedIntervalController.dispose();
    super.dispose();
  }

  void _toggleAdvanceGroup(String groupId) {
    setState(() {
      if (_advanceGroupIds.contains(groupId)) {
        _advanceGroupIds.remove(groupId);
      } else {
        _advanceGroupIds.add(groupId);
      }
    });
  }

  void _addEscalationGroup(String groupId) {
    if (_escalationGroupIds.contains(groupId)) return;
    setState(() {
      _escalationGroupIds.add(groupId);
    });
  }

  void _removeEscalationGroup(String groupId) {
    setState(() {
      _escalationGroupIds.remove(groupId);
    });
  }

  void _moveEscalationGroup(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _escalationGroupIds.removeAt(oldIndex);
      _escalationGroupIds.insert(newIndex, item);
    });
  }

  void _save() {
    final advanceMinutes = int.tryParse(_advanceMinutesController.text) ?? 30;
    final delayedInterval =
        int.tryParse(_delayedIntervalController.text) ?? 30;

    context.read<CompanyCubit>().updateEscalationParameters(
      advanceWarningMinutes: advanceMinutes,
      advanceWarningGroupIds: _advanceGroupIds,
      delayedNotificationIntervalMinutes: delayedInterval,
      escalationGroupIds: _escalationGroupIds,
    );
  }

  String _getGroupName(String id) {
    for (final g in widget.permissionGroups) {
      if (g.id == id) return g.name;
    }
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<SessionCubit, bool>(
      (cubit) => cubit.state.user.isAdmin,
    );
    final isSaving = context.select<CompanyCubit, bool>(
      (cubit) => cubit.state.status == StateStatus.saving,
    );

    final availableGroupsForEscalation = widget.permissionGroups
        .where((g) => !_escalationGroupIds.contains(g.id))
        .toList();

    return Card(
      margin: const EdgeInsets.only(top: Sizes.p16),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Title
            Row(
              children: [
                const PlatformIcon(
                  materialIcon: Icons.notifications_active_outlined,
                  cupertinoIcon: CupertinoIcons.bell,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BaseText.titleMedium(
                        'Escalonamento & Avisos de SLA'.hardcoded,
                      ),
                      gapH4,
                      BaseText.bodySmall(
                        'Configure avisos prévios de expiração e notificações em cascata para ordens atrasadas.'
                            .hardcoded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH16,
            const Divider(height: 1),
            gapH16,

            // Section 1: Advance Warning
            Row(
              children: [
                const PlatformIcon(
                  materialIcon: Icons.timer_outlined,
                  cupertinoIcon: CupertinoIcons.timer,
                ),
                gapW8,
                BaseText.title('Aviso Prévio de Vencimento'.hardcoded),
              ],
            ),
            gapH4,
            BaseText.bodySmall(
              'Tempo de antecedência antes do prazo limite do SLA. O usuário responsável é sempre notificado.'
                  .hardcoded,
            ),
            gapH8,
            TextFormField(
              controller: _advanceMinutesController,
              enabled: isAdmin,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Minutos de antecedência'.hardcoded,
                suffixText: 'minutos'.hardcoded,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Sizes.p12,
                  vertical: Sizes.p8,
                ),
              ),
            ),
            gapH12,
            BaseText.bodySmall('Grupos notificados no aviso prévio:'.hardcoded),
            gapH8,
            if (widget.permissionGroups.isEmpty)
              BaseText.bodySmall(
                'Nenhum grupo de permissão disponível.'.hardcoded,
              )
            else
              Wrap(
                spacing: Sizes.p8,
                runSpacing: Sizes.p4,
                children: widget.permissionGroups.map((group) {
                  final isSelected = _advanceGroupIds.contains(group.id);
                  return FilterChip(
                    label: Text(group.name),
                    selected: isSelected,
                    onSelected: isAdmin ? (_) => _toggleAdvanceGroup(group.id) : null,
                  );
                }).toList(),
              ),

            gapH20,
            const Divider(height: 1),
            gapH16,

            // Section 2: Delayed Escalation
            Row(
              children: [
                const PlatformIcon(
                  materialIcon: Icons.warning_amber_rounded,
                  cupertinoIcon: CupertinoIcons.exclamationmark_triangle,
                ),
                gapW8,
                BaseText.title('Escalonamento de Ordens Atrasadas'.hardcoded),
              ],
            ),
            gapH4,
            BaseText.bodySmall(
              'Intervalo para reaviso pós-vencimento. A cada intervalo, o próximo nível da hierarquia é acionado em cascata.'
                  .hardcoded,
            ),
            gapH8,
            TextFormField(
              controller: _delayedIntervalController,
              enabled: isAdmin,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Intervalo de reaviso após vencimento'.hardcoded,
                suffixText: 'minutos'.hardcoded,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Sizes.p12,
                  vertical: Sizes.p8,
                ),
              ),
            ),
            gapH12,

            // Escalation Hierarchy Reorderable List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BaseText.bodySmall(
                  'Ordem de escalonamento (níveis sucessivos):'.hardcoded,
                ),
                if (isAdmin && availableGroupsForEscalation.isNotEmpty)
                  PopupMenuButton<String>(
                    tooltip: 'Adicionar grupo ao escalonamento'.hardcoded,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onSelected: _addEscalationGroup,
                    itemBuilder: (context) => availableGroupsForEscalation
                        .map(
                          (g) => PopupMenuItem(
                            value: g.id,
                            child: Text(g.name),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
            gapH8,
            if (_escalationGroupIds.isEmpty)
              Container(
                padding: const EdgeInsets.all(Sizes.p12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                itemCount: _escalationGroupIds.length,
                onReorder: isAdmin ? _moveEscalationGroup : (_, _) {},
                itemBuilder: (context, index) {
                  final groupId = _escalationGroupIds[index];
                  final groupName = _getGroupName(groupId);
                  return Container(
                    key: ValueKey(groupId),
                    margin: const EdgeInsets.only(bottom: Sizes.p4),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(Sizes.p8),
                      border: Border.all(
                        color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: context.colorScheme.primaryContainer,
                        child: BaseText.bodySmall(
                          '${index + 1}',
                          color: context.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: BaseText.bodyMedium(groupName),
                      subtitle: BaseText.bodySmall(
                        'Nível ${index + 1}: acionado após ${(index + 1) * (int.tryParse(_delayedIntervalController.text) ?? 30)} min de atraso'
                            .hardcoded,
                      ),
                      trailing: isAdmin
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BaseIconButton(
                                  platformIcon: const PlatformIcon(
                                    materialIcon: Icons.delete_outline,
                                    cupertinoIcon: CupertinoIcons.trash,
                                  ),
                                  onPressed: () => _removeEscalationGroup(groupId),
                                ),
                                const Icon(Icons.drag_handle, size: 20),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),

            if (isAdmin) ...[
              gapH20,
              BaseButton(
                onTap: isSaving ? null : _save,
                isLoading: isSaving,
                text: 'Salvar parâmetros de escalonamento'.hardcoded,
                expandWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
