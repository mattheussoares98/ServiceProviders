import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_profile_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/dropdown/base_dropdown.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';

class ServiceProviderProfileDropdown extends StatelessWidget {
  const ServiceProviderProfileDropdown({
    super.key,
    required this.onChanged,
    required this.selectedProfileId,
  });

  final String? selectedProfileId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final profiles = context.select<ServiceProvidersCubit, List<ServiceProviderProfileEntity>>(
      (cubit) => cubit.state.profiles,
    );

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
    );
  }
}
