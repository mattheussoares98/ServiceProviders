import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedGroupDropdown extends StatelessWidget {
  const SelectedGroupDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PermissionsCubit, PermissionsState, String?>(
      selector: (state) => state.selectedGroupId,
      builder: (context, selectedGroupId) {
        final usersCubit = context.read<UsersCubit>();
        final groups = usersCubit.state.permissionGroups;

        return BaseDropDown<String>(
          label: 'Grupo de permissões'.hardcoded,
          hint: BaseText('Selecionar grupo'.hardcoded),
          selectedItem: selectedGroupId,
          showLabelAtTopLeft: true,
          adviceMessage:
              'Atenção! Ao selecionar o grupo administrador, todas as permissões serão herdadas do grupo de administrador.'
                  .hardcoded,
          items: groups.map((g) {
            return DropdownMenuItem<String>(
              value: g.id,
              child: BaseText(g.name),
            );
          }).toList(),
          onChanged: (groupId) {
            context.read<PermissionsCubit>().changeUserGroup(
              groupId,
              usersCubit,
            );
          },
        );
      },
    );
  }
}
