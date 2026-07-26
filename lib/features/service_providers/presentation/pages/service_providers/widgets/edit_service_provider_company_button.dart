import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/buttons/base_icon_button.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/platform_icon.dart';

class EditServiceProviderCompanyButton extends StatelessWidget {
  const EditServiceProviderCompanyButton({super.key, required this.companyId});
  final String companyId;

  @override
  Widget build(BuildContext context) {
    return BaseIconButton(
      permission: const ActionPermission.resource(
        resource: ResourceType.serviceProviders,
        action: PermissionAction.update,
      ),
      platformIcon: const PlatformIcon(
        materialIcon: Icons.edit_outlined,
        cupertinoIcon: CupertinoIcons.pencil,
      ),
      onPressed: () => context
          .read<ServiceProvidersCubit>()
          .navigateToCreateUpdateServiceProviderCompany(companyId),
    );
  }
}
