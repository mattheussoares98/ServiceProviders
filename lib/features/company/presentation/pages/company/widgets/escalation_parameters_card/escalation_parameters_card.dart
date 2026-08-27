import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/presentation/cubits/company/company_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/extensions/build_context_extension.dart';

part 'advance_warning_section.dart';
part 'card_header.dart';
part 'delayed_escalation_section.dart';
part 'escalation_hierarchy_list.dart';
part 'save_escalation_button.dart';

class EscalationParametersCard extends HookWidget {
  const EscalationParametersCard({
    super.key,
    required this.parameters,
    required this.permissionGroups,
  });

  final CompanyParameterEntity parameters;
  final List<PermissionGroupEntity> permissionGroups;

  @override
  Widget build(BuildContext context) {
    final advanceMinutesController = useTextEditingController(
      text: parameters.advanceWarningMinutes.toString(),
    );
    final delayedIntervalController = useTextEditingController(
      text: parameters.delayedNotificationIntervalMinutes.toString(),
    );
    final advanceFocusNode = useFocusNode();
    final delayedFocusNode = useFocusNode();
    useListenable(delayedIntervalController);

    final advanceGroupIds = useState<List<String>>(
      List.from(parameters.advanceWarningGroupIds),
    );
    final escalationGroupIds = useState<List<String>>(
      List.from(parameters.escalationGroupIds),
    );

    useEffect(() {
      advanceMinutesController.text = parameters.advanceWarningMinutes
          .toString();
      delayedIntervalController.text = parameters
          .delayedNotificationIntervalMinutes
          .toString();
      advanceGroupIds.value = List.from(parameters.advanceWarningGroupIds);
      escalationGroupIds.value = List.from(parameters.escalationGroupIds);
      return null;
    }, [parameters]);

    final isAdmin = context.select<SessionCubit, bool>(
      (cubit) => cubit.state.user.isAdmin,
    );
    final isSaving = context.select<CompanyCubit, bool>(
      (cubit) => cubit.state.status == StateStatus.saving,
    );

    final availableGroupsForEscalation = permissionGroups
        .where((g) => !escalationGroupIds.value.contains(g.id))
        .toList();

    void toggleAdvanceGroup(String groupId) {
      final current = List<String>.from(advanceGroupIds.value);
      if (current.contains(groupId)) {
        current.remove(groupId);
      } else {
        current.add(groupId);
      }
      advanceGroupIds.value = current;
    }

    void addEscalationGroup(String groupId) {
      if (escalationGroupIds.value.contains(groupId)) return;
      escalationGroupIds.value = [...escalationGroupIds.value, groupId];
    }

    void removeEscalationGroup(String groupId) {
      escalationGroupIds.value = escalationGroupIds.value
          .where((id) => id != groupId)
          .toList();
    }

    void moveEscalationGroup(int oldIndex, int newIndex) {
      var adjustedNewIndex = newIndex;
      if (adjustedNewIndex > oldIndex) adjustedNewIndex -= 1;
      final current = List<String>.from(escalationGroupIds.value);
      final item = current.removeAt(oldIndex);
      current.insert(adjustedNewIndex, item);
      escalationGroupIds.value = current;
    }

    void save() {
      final advanceMinutes = int.tryParse(advanceMinutesController.text) ?? 30;
      final delayedInterval =
          int.tryParse(delayedIntervalController.text) ?? 30;

      context.read<CompanyCubit>().updateEscalationParameters(
        advanceWarningMinutes: advanceMinutes,
        advanceWarningGroupIds: advanceGroupIds.value,
        delayedNotificationIntervalMinutes: delayedInterval,
        escalationGroupIds: escalationGroupIds.value,
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: Sizes.p16),
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CardHeader(),
            gapH16,
            const Divider(height: 1),
            gapH16,
            _AdvanceWarningSection(
              advanceMinutesController: advanceMinutesController,
              focusNode: advanceFocusNode,
              advanceGroupIds: advanceGroupIds.value,
              permissionGroups: permissionGroups,
              isAdmin: isAdmin,
              onToggleAdvanceGroup: toggleAdvanceGroup,
            ),
            gapH20,
            const Divider(height: 1),
            gapH16,
            _DelayedEscalationSection(
              delayedIntervalController: delayedIntervalController,
              focusNode: delayedFocusNode,
              isAdmin: isAdmin,
            ),
            gapH12,
            _EscalationHierarchyList(
              escalationGroupIds: escalationGroupIds.value,
              availableGroups: availableGroupsForEscalation,
              delayedIntervalController: delayedIntervalController,
              permissionGroups: permissionGroups,
              isAdmin: isAdmin,
              onAddGroup: addEscalationGroup,
              onRemoveGroup: removeEscalationGroup,
              onReorder: moveEscalationGroup,
            ),
            if (isAdmin) ...[
              gapH20,
              _SaveEscalationButton(isSaving: isSaving, onSave: save),
            ],
          ],
        ),
      ),
    );
  }
}
