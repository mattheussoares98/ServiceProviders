part of '../create_update_work_order_page.dart';

class _ServiceProviderProfileDropdown extends StatelessWidget {
  const _ServiceProviderProfileDropdown({
    required this.onChanged,
    required this.selectedProfileId,
    required this.companyId,
  });

  final String? companyId;
  final String? selectedProfileId;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (companyId?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    final profiles = context
        .select<ServiceProvidersCubit, List<ServiceProviderProfileEntity>>(
          (cubit) => cubit.state.profiles[companyId!] ?? [],
        );

    if (profiles.isEmpty) {
      return const SizedBox.shrink();
    }

    final dropdownItems = profiles
        .map(
          (profile) => DropdownMenuItem(
            value: profile.id,
            child: BaseText(profile.name),
          ),
        )
        .toList();

    return BaseDropDown<String?>(
      key: const ValueKey('ServiceProviderProfile'),
      label: 'Técnico / Prestador (opcional)'.hardcoded,
      showLabelAtTopLeft: true,
      selectedItem: selectedProfileId,
      items: dropdownItems,
      onChanged: onChanged,
      onClear: () => onChanged?.call(null),
    );
  }
}
