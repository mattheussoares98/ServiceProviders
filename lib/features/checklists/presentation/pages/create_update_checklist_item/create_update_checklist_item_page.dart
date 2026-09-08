import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_entity.dart';
import 'package:o_jogo_da_obra/features/checklists/domain/entities/checklist_item_type.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/cubits/checklist_templates/checklist_templates_cubit.dart';
import 'package:o_jogo_da_obra/features/checklists/presentation/pages/create_update_checklist_item/widgets/checklist_item_form.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_scaffold.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/loading/observe_running.dart';

@RoutePage()
class CreateUpdateChecklistItemPage extends HookWidget {
  const CreateUpdateChecklistItemPage({
    super.key,
    required this.templateId,
    this.item,
    this.sortOrder = 0,
  });

  final String templateId;
  final ChecklistItemEntity? item;
  final int sortOrder;

  @override
  Widget build(BuildContext context) {
    observeRunning([
      ObservedLoadingTarget.section(
        context.read<ChecklistTemplatesCubit>(),
        ChecklistTemplatesSections.saveItem,
      ),
    ]);

    return BaseScaffold(
      appBar: BaseAppBar(
        title: item != null
            ? 'Editando item'.hardcoded
            : 'Criando item'.hardcoded,
      ),
      body: ChecklistItemForm(
        templateId: templateId,
        item: item,
        sortOrder: sortOrder,
        initialType: item?.type ?? ChecklistItemType.boolean,
      ),
    );
  }
}
