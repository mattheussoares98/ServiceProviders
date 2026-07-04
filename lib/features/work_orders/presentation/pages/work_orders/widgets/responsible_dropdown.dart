import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResponsibleDropdown extends StatelessWidget {
  const ResponsibleDropdown({
    super.key,
    required this.onChanged,
    required this.responsibleId,
  });
  final String? responsibleId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = context.select<UsersCubit, List<UserProfileEntity>>(
      (cubit) => cubit.state.users,
    );
    final userDropdownItems = items
        .map(
          (user) =>
              DropdownMenuItem(value: user.id, child: BaseText(user.name)),
        )
        .toList();
    return BaseDropDown<String?>(
      key: const ValueKey('AssignedTo'),
      label: 'Responsável (opcional)'.hardcoded,
      showLabelAtTopLeft: true,
      selectedItem: responsibleId,
      items: userDropdownItems,
      onChanged: onChanged,
    );
  }
}
