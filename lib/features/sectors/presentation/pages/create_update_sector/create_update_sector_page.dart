import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/alert_dialogs.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/min_length_validator.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';

@RoutePage()
class CreateUpdateSectorPage extends HookWidget {
  const CreateUpdateSectorPage({super.key, this.sector});

  final SectorEntity? sector;

  @override
  Widget build(BuildContext context) {
    observeLoading(
      [context.read<SectorsCubit>()],
      statuses: {StateStatus.saving, StateStatus.deleting},
    );

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final nameController = useTextEditingController(text: sector?.name);

    Future<void> submit() async {
      if (formKey.currentState?.validate() != true) return;

      final success = await context.read<SectorsCubit>().saveSector(
        id: sector?.id,
        name: nameController.text,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    final isEditing = sector != null;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando setor'.hardcoded
            : 'Criando setor'.hardcoded,
        actions: [
          if (sector != null)
            BaseIconButton(
              onPressed: () {
                showAlertDialog(
                  context: context,
                  title: 'Atenção!'.hardcoded,
                  contentText:
                      'Deseja realmente excluir o setor "${sector!.name}"?'
                          .hardcoded,
                  defaultActionText: 'Sim'.hardcoded,
                  cancelActionText: 'Não'.hardcoded,
                  onOkPressed: () async {
                    final succeeds = await context
                        .read<SectorsCubit>()
                        .deleteSector(sector!.id);

                    if (succeeds && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
              permission: const ActionPermission.resource(
                resource: ResourceType.sectors,
                action: PermissionAction.delete,
              ),
              platformIcon: const PlatformIcon(
                materialIcon: Icons.delete,
                cupertinoIcon: CupertinoIcons.delete,
                color: Colors.red,
              ),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BaseTextFormField(
              labelText: 'Nome do setor *'.hardcoded,
              hintText: 'Ex: manutenção'.hardcoded,
              controller: nameController,
              validator: FormValidators.compose([
                NonEmptyValidator(),
                MinLengthValidator(3),
              ]),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => submit(),
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
                    animation: nameController,
                    builder: (context, child) {
                      final hasChanged =
                          nameController.text.trim() !=
                          (sector?.name.trim() ?? '');
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
