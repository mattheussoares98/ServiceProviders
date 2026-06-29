import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupPermissionDropdown extends StatelessWidget {
  const GroupPermissionDropdown({super.key, required this.selectedGroup});

  final ValueNotifier<PermissionGroupEntity?> selectedGroup;

  @override
  Widget build(BuildContext context) {
    final permissionGroups = context.select(
      (UsersCubit cubit) => cubit.state.permissionGroups,
    );

    if (permissionGroups.isEmpty) {
      return BaseText.error(
        'Nenhum grupo de permissão disponível. Crie um grupo antes de convidar.'
            .hardcoded,
      );
    }

    return BaseDropDown<PermissionGroupEntity?>(
      selectedItem: selectedGroup.value,
      label: 'Grupo de Permissão'.hardcoded,
      hint: BaseText('Selecione o grupo'.hardcoded),
      showLabelAtTopLeft: true,
      items: permissionGroups.map((group) {
        return DropdownMenuItem<PermissionGroupEntity>(
          value: group,
          child: BaseText(group.name),
        );
      }).toList(),
      onChanged: (val) => selectedGroup.value = val,
      validator: (value) =>
          value == null ? 'Selecione um grupo'.hardcoded : null,
    );
  }
}
