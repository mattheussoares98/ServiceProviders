part of '../create_update_work_order_page.dart';

class _ResponsibleDropdown extends StatelessWidget {
  const _ResponsibleDropdown({
    required this.onChanged,
    required this.selectedId,
  });
  final String? selectedId;
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
      selectedItem: selectedId,
      items: userDropdownItems,
      onChanged: onChanged,
    );
  }
}
