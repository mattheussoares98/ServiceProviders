import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/edit_group_permissions/widgets/group_permissions_header.dart';
import 'package:clean_architecture/features/users/presentation/pages/permissions/edit_group_permissions/widgets/resource_permission_card.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

@RoutePage()
class EditGroupPermissionsPage extends HookWidget {
  const EditGroupPermissionsPage({super.key, required this.group});
  final PermissionGroupEntity group;

  @override
  Widget build(BuildContext context) {
    final isAdminGroup = useMemoized(
      () => group.name.toLowerCase() == 'administrador',
      [group],
    );

    final localPermissions = useMemoized(() {
      final map = <ResourceType, ValueNotifier<Set<PermissionAction>>>{};
      for (final resource in ResourceType.values) {
        final initialActions = <PermissionAction>{};
        if (isAdminGroup) {
          initialActions.addAll(PermissionAction.values);
        } else {
          final perm = group.permissions.firstWhereOrNull(
            (p) => p.resource == resource,
          );
          if (perm != null) {
            initialActions.addAll(perm.actions);
          }
        }
        map[resource] = ValueNotifier<Set<PermissionAction>>(initialActions);
      }
      return map;
    }, [group, isAdminGroup]);

    useEffect(() {
      return () {
        for (final notifier in localPermissions.values) {
          notifier.dispose();
        }
      };
    }, [localPermissions]);

    final onSave = useCallback(() async {
      final updatedPermissions = localPermissions.entries
          .where((e) => e.value.value.isNotEmpty)
          .map(
            (e) => ResourcePermissionEntity(
              resource: e.key,
              actions: e.value.value,
            ),
          )
          .toList();

      final updatedGroup = group.copyWith(permissions: updatedPermissions);

      final success = await context.read<UsersCubit>().savePermissionGroup(
        updatedGroup,
        isUpdate: true,
      );

      if (success && context.mounted) {
        context.router.pop();
      }
    }, [localPermissions, group]);

    return BaseScaffold(
      appBar: BaseAppBar(
        title: 'Editar Grupo'.hardcoded,
        actions: [
          if (!isAdminGroup)
            BlocSelector<UsersCubit, UsersState, bool>(
              selector: (state) => state.status == StateStatus.saving,
              builder: (context, isSaving) {
                return BaseTextButton(
                  onPressed: isSaving ? null : onSave,
                  text: 'Salvar'.hardcoded,
                  isLoading: isSaving,
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GroupPermissionsHeader(group: group, isAdminGroup: isAdminGroup),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ResourceType.values.length,
              itemBuilder: (context, index) {
                final resource = ResourceType.values[index];
                return ResourcePermissionCard(
                  resource: resource,
                  notifier: localPermissions[resource]!,
                  isAdminGroup: isAdminGroup,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
