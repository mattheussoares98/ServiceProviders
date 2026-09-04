import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/presentation/cubits/permissions/permissions_cubit.dart';
import 'package:o_jogo_da_obra/features/users/presentation/extensions/permission_extensions.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/base_switch.dart';
import 'package:o_jogo_da_obra/shared_ui/ui/base/text/base_text.dart';
import 'package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart';

class ResourcePermissionCard extends StatelessWidget {
  const ResourcePermissionCard({
    super.key,
    required this.resource,
    required this.allowedPermissions,
    required this.isAdminGroup,
  });

  final ResourceType resource;
  final Set<PermissionAction> allowedPermissions;
  final bool isAdminGroup;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BaseText(resource.label),
            const Divider(height: Sizes.p20),
            ...[
              PermissionAction.create,
              PermissionAction.update,
              PermissionAction.delete,
            ].map((action) {
              return _Item(
                key: ValueKey('${resource.code}.$action'),
                action: action,
                isAdminGroup: isAdminGroup,
                resource: resource,
                allowedPermissions: allowedPermissions,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    super.key,
    required this.action,
    required this.isAdminGroup,
    required this.resource,
    required this.allowedPermissions,
  });

  final PermissionAction action;
  final bool isAdminGroup;
  final ResourceType resource;
  final Set<PermissionAction> allowedPermissions;

  @override
  Widget build(BuildContext context) {
    final hasPermission = allowedPermissions.contains(action);

    return BaseSwitch(
      title: action.label,
      value: hasPermission,
      onChanged: isAdminGroup
          ? null
          : (value) => context.read<PermissionsCubit>().toggleGroupPermission(
              resource,
              action,
              value,
            ),
    );
  }
}
