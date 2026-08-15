import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_applies_to.dart';
import 'package:o_jogo_da_obra/features/sla_policies/domain/entities/sla_policy_entity.dart';
import 'package:o_jogo_da_obra/features/sla_policies/presentation/cubits/sla_policies/sla_policies_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

@RoutePage()
class CreateUpdateSlaPolicyPage extends HookWidget {
  const CreateUpdateSlaPolicyPage({super.key, this.slaPolicy});

  final SlaPolicyEntity? slaPolicy;
  @override
  Widget build(BuildContext context) {
    observeLoading([
      ObservedLoadingTarget(
        context.read<SlaPoliciesCubit>(),
        statuses: {StateStatus.saving, StateStatus.deleting},
      ),
    ]);

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: slaPolicy?.name);
    final hoursController = useTextEditingController(
      text: slaPolicy?.targetHours.toString() ?? '',
    );
    final appliesToState = useState<SlaAppliesTo>(
      slaPolicy?.appliesTo ?? SlaAppliesTo.both,
    );
    final hoursFocusNode = useFocusNode();

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final hours = int.tryParse(hoursController.text.trim()) ?? 0;

      final success = await context.read<SlaPoliciesCubit>().saveSlaPolicy(
        id: slaPolicy?.id,
        name: nameController.text.trim(),
        targetHours: hours,
        appliesTo: appliesToState.value,
        createdAt: slaPolicy?.createdAt,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop(true);
      }
    }

    final isEditing = slaPolicy != null;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando política de SLA'.hardcoded
            : 'Criando política de SLA'.hardcoded,
        actions: [
          if (isEditing)
            BaseIconButton(
              permission: const ActionPermission.resource(
                resource: ResourceType.slaPolicies,
                action: PermissionAction.delete,
              ),
              onPressed: () async {
                final proceed = await showAlertDialog(
                  context: context,
                  title: 'Atenção!'.hardcoded,
                  contentText:
                      'Tem certeza que deseja excluir a política "${slaPolicy!.name}"?'
                          .hardcoded,
                  defaultActionText: 'Sim'.hardcoded,
                  cancelActionText: 'Não'.hardcoded,
                );

                if (context.mounted && proceed == true) {
                  final succeeds = await context
                      .read<SlaPoliciesCubit>()
                      .deleteSlaPolicy(slaPolicy!.id);

                  if (succeeds && context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              platformIcon: const PlatformIcon(
                materialIcon: Icons.delete_outline,
                cupertinoIcon: CupertinoIcons.trash,
                color: Colors.red,
              ),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            BaseTextFormField(
              labelText: 'Nome da política *'.hardcoded,
              hintText: 'Ex: SLA urgente (4h)'.hardcoded,
              controller: nameController,
              validator: FormValidators.compose([NonEmptyValidator()]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => hoursFocusNode.requestFocus(),
            ),
            gapH16,
            BaseTextFormField(
              labelText: 'Horas meta (resolução) *'.hardcoded,
              hintText: 'Ex: 24'.hardcoded,
              controller: hoursController,
              keyboardType: TextInputType.number,
              focusNode: hoursFocusNode,
              validator: FormValidators.compose([NonEmptyValidator()]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.done,
            ),
            gapH16,
            BaseDropDown<SlaAppliesTo>(
              label: 'Aplica-se a'.hardcoded,
              selectedItem: appliesToState.value,
              showLabelAtTopLeft: true,
              hint: BaseText('Aplica-se a'.hardcoded),
              items: SlaAppliesTo.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (val) {
                appliesToState.value = val;
              },
            ),
            gapH24,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: BaseTextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancelar'.hardcoded,
                    color: Colors.red,
                  ),
                ),
                gapW12,
                Expanded(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      nameController,
                      hoursController,
                    ]),
                    builder: (context, _) {
                      final nameHasChanged =
                          nameController.text.trim() !=
                          (slaPolicy?.name.trim() ?? '');
                      final hoursHasChanged =
                          hoursController.text.trim() !=
                          (slaPolicy?.targetHours.toString().trim() ?? '');
                      final hasChanged = nameHasChanged || hoursHasChanged;
                      return BaseButton(
                        onTap: hasChanged ? submit : null,
                        width: Sizes.p120,
                        text: 'Salvar'.hardcoded,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
