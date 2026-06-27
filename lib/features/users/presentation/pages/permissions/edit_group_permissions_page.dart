import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class EditGroupPermissionsPage extends StatefulWidget {
  const EditGroupPermissionsPage({super.key, required this.group});

  final PermissionGroupEntity group;
  //TODO review this page
  @override
  State<EditGroupPermissionsPage> createState() =>
      _EditGroupPermissionsPageState();
}

class _EditGroupPermissionsPageState extends State<EditGroupPermissionsPage> {
  late Map<ResourceType, Set<PermissionAction>> _localPermissions;
  late bool _isAdminGroup;

  @override
  void initState() {
    super.initState();
    _isAdminGroup = widget.group.name.toLowerCase() == 'administrador';
    _initializePermissions();
  }

  void _initializePermissions() {
    _localPermissions = {};
    for (final resource in ResourceType.values) {
      _localPermissions[resource] = {};
    }

    if (_isAdminGroup) {
      // Admin has all permissions
      for (final resource in ResourceType.values) {
        _localPermissions[resource]!.addAll(PermissionAction.values);
      }
    } else {
      for (final perm in widget.group.permissions) {
        _localPermissions[perm.resource] = Set.from(perm.actions);
      }
    }
  }

  String _getResourceLabel(ResourceType resource) {
    switch (resource) {
      case ResourceType.workOrders:
        return 'Ordens de Serviço'.hardcoded;
      case ResourceType.assets:
        return 'Ativos'.hardcoded;
      case ResourceType.locations:
        return 'Locais'.hardcoded;
      case ResourceType.reports:
        return 'Relatórios'.hardcoded;
      case ResourceType.attachments:
        return 'Anexos'.hardcoded;
      case ResourceType.checklists:
        return 'Checklists'.hardcoded;
      case ResourceType.maintenancePlans:
        return 'Planos de Manutenção'.hardcoded;
      case ResourceType.users:
        return 'Usuários'.hardcoded;
      case ResourceType.categories:
        return 'Categorias'.hardcoded;
    }
  }

  void _togglePermission(
    ResourceType resource,
    PermissionAction action,
    bool value,
  ) {
    if (_isAdminGroup) return; // Cannot edit admin group

    setState(() {
      if (value) {
        _localPermissions[resource]!.add(action);
      } else {
        _localPermissions[resource]!.remove(action);
      }
    });
  }

  Future<void> _save() async {
    final updatedPermissions = _localPermissions.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => ResourcePermissionEntity(resource: e.key, actions: e.value))
        .toList();

    final updatedGroup = widget.group.copyWith(permissions: updatedPermissions);

    final cubit = context.read<UsersCubit>();
    final success = await cubit.savePermissionGroup(
      updatedGroup,
      isUpdate: true,
    );

    if (success && mounted) {
      context.router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: 'Editar Grupo'.hardcoded,
        actions: [
          if (!_isAdminGroup)
            BlocBuilder<UsersCubit, UsersState>(
              builder: (context, state) {
                final isSaving = state.status == StateStatus.saving;
                return TextButton(
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? const SizedBox(
                          width: Sizes.p16,
                          height: Sizes.p16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : BaseText(
                          'Salvar'.hardcoded,
                          color: Theme.of(context).primaryColor,
                        ),
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
            BaseText.titleMedium(widget.group.name),
            const SizedBox(height: Sizes.p4),
            BaseText(
              widget.group.isDefault
                  ? 'Grupo de permissão padrão do sistema.'.hardcoded
                  : 'Grupo de permissão personalizado.'.hardcoded,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: Sizes.p16),
            if (_isAdminGroup) ...[
              Container(
                padding: const EdgeInsets.all(Sizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.black05,
                  borderRadius: BorderRadius.circular(Sizes.p8),
                  border: Border.all(color: AppColors.black10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: Sizes.p12),
                    Expanded(
                      child: BaseText(
                        'Este é o grupo Administrador padrão. Ele possui acesso total irrestrito a todos os recursos do sistema e não pode ser editado.'
                            .hardcoded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.p16),
            ],
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ResourceType.values.length,
              itemBuilder: (context, index) {
                final resource = ResourceType.values[index];
                final resourceLabel = _getResourceLabel(resource);
                final actions = _localPermissions[resource]!;

                return Card(
                  margin: const EdgeInsets.only(bottom: Sizes.p12),
                  elevation: 0,
                  color: isDark ? AppColors.fadeLight : AppColors.black05,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Sizes.p8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Sizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaseText(resourceLabel),
                        const Divider(height: Sizes.p20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          children: PermissionAction.values.map((action) {
                            final hasPermission = actions.contains(action);
                            String actionLabel = '';
                            switch (action) {
                              case PermissionAction.create:
                                actionLabel = 'Criar'.hardcoded;
                              case PermissionAction.read:
                                actionLabel = 'Ler'.hardcoded;
                              case PermissionAction.update:
                                actionLabel = 'Atualizar'.hardcoded;
                              case PermissionAction.delete:
                                actionLabel = 'Excluir'.hardcoded;
                            }

                            return SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: BaseText(actionLabel),
                              value: hasPermission,
                              tileColor: Theme.of(context).primaryColor,
                              onChanged: _isAdminGroup
                                  ? null
                                  : (value) => _togglePermission(
                                      resource,
                                      action,
                                      value,
                                    ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
