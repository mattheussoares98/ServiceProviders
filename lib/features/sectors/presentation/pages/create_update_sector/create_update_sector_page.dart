import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/presentation/cubits/sectors/sectors_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/session/session_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/form_field/base_text_form_field.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_loading.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/form_validators.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/validators/non_empty_validator.dart';
import 'package:uuid/uuid.dart';

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

      final companyId = context.read<SessionCubit>().state.user.companyId;
      final now = DateTime.now();
      final newOrUpdatedSector = SectorEntity(
        id: sector?.id ?? const Uuid().v4(),
        companyId: companyId,
        name: nameController.text.trim(),
        createdAt: sector?.createdAt ?? now,
        updatedAt: now,
      );

      final success = await context.read<SectorsCubit>().saveSector(
        newOrUpdatedSector,
        isUpdate: sector != null,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop(true);
      }
    }

    final isEditing = sector != null;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: isEditing
            ? 'Editando setor'.hardcoded
            : 'Criando setor'.hardcoded,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BaseTextFormField(
                labelText: 'Nome do Setor *'.hardcoded,
                hintText: 'Ex: Manutenção'.hardcoded,
                controller: nameController,
                validator: FormValidators.compose([NonEmptyValidator()]),
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
                  Expanded(
                    child: BaseButton(
                      onTap: submit,
                      width: Sizes.p120,
                      text: 'Salvar'.hardcoded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
