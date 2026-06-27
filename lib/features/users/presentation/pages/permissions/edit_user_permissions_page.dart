import 'package:auto_route/auto_route.dart';
import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/presentation/cubits/users/users_cubit.dart';
import 'package:clean_architecture/shared_ui/cubits/base/base_cubit.dart';
import 'package:clean_architecture/shared_ui/ui/base/app_bar/base_app_bar.dart';
import 'package:clean_architecture/shared_ui/ui/base/base_scaffold.dart';
import 'package:clean_architecture/shared_ui/ui/base/text/base_text.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class EditUserPermissionsPage extends StatefulWidget {
  const EditUserPermissionsPage({super.key, required this.user});

  final UserProfileEntity user;

  @override
  State<EditUserPermissionsPage> createState() =>
      _EditUserPermissionsPageState();
}
//TODO review this page

class _EditUserPermissionsPageState extends State<EditUserPermissionsPage> {
  late Map<String, String>
  _localOverrides; // key: 'resource.action', value: 'inherit' | 'active' | 'inactive'
  late PermissionGroupEntity _userGroup;

  @override
  void initState() {
    super.initState();
    _initializeUserGroup();
    _initializeOverrides();
  }

  void _initializeUserGroup() {
    final groups = context.read<UsersCubit>().state.permissionGroups;
    _userGroup = groups.firstWhere(
      (g) => g.id == widget.user.permissionGroupId,
      orElse: () => PermissionGroupEntity(
        id: '',
        companyId: '',
        name: 'Sem Grupo'.hardcoded,
        permissions: const [],
        isDefault: false,
        createdAt: DateTime.now(),
      ),
    );
  }

  void _initializeOverrides() {
    _localOverrides = {};

    // Fill with default 'inherit' for all possible resource action pairs
    for (final resource in ResourceType.values) {
      for (final action in PermissionAction.values) {
        final key = '${resource.code}.${action.code}';

        if (widget.user.permissions.containsKey(key)) {
          final isAllowed = widget.user.permissions[key]!;
          _localOverrides[key] = isAllowed ? 'active' : 'inactive';
        } else {
          _localOverrides[key] = 'inherit';
        }
      }
    }
  }

  bool _isGroupActionEnabled(ResourceType resource, PermissionAction action) {
    if (_userGroup.name.toLowerCase() == 'administrador') return true;

    for (final perm in _userGroup.permissions) {
      if (perm.resource == resource) {
        return perm.actions.contains(action);
      }
    }
    return false;
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

  void _setOverride(
    ResourceType resource,
    PermissionAction action,
    String value,
  ) {
    final key = '${resource.code}.${action.code}';
    setState(() {
      _localOverrides[key] = value;
    });
  }

  Future<void> _save() async {
    final Map<String, bool> finalPermissions = {};

    _localOverrides.forEach((key, value) {
      if (value == 'active') {
        finalPermissions[key] = true;
      } else if (value == 'inactive') {
        finalPermissions[key] = false;
      }
      // 'inherit' values are omitted, so they fallback to group permissions
    });

    final updatedUser = widget.user.copyWith(permissions: finalPermissions);

    final cubit = context.read<UsersCubit>();
    final success = await cubit.updateUserProfile(updatedUser);

    if (success && mounted) {
      context.router.pop();
    }
  }

  Widget _buildThreeStateToggle({
    required String currentValue,
    required bool inheritedValue,
    required ValueChanged<String> onChanged,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildOption(String value, String label, Color activeColor) {
      final isSelected = currentValue == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(Sizes.p8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: isDark ? AppColors.black10 : AppColors.black05,
        borderRadius: BorderRadius.circular(Sizes.p8),
        border: Border.all(
          color: isDark ? AppColors.black20 : AppColors.black10,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          buildOption(
            'inherit',
            'Herdar (${inheritedValue ? "Ativo" : "Inativo"})'.hardcoded,
            Theme.of(context).primaryColor,
          ),
          buildOption('active', 'Ativo'.hardcoded, Colors.green.shade600),
          buildOption('inactive', 'Inativo'.hardcoded, Colors.red.shade600),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseScaffold(
      appBar: BaseAppBar(
        title: 'Permissões do Usuário'.hardcoded,
        actions: [
          if (!widget.user.isAdmin)
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
                      : BaseText.bodyMedium(
                          'Salvar'.hardcoded,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
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
            BaseText.titleMedium(widget.user.name),
            const SizedBox(height: Sizes.p4),
            BaseText(
              '${widget.user.email} • Cargo: ${_userGroup.name}'.hardcoded,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: Sizes.p16),
            if (widget.user.isAdmin) ...[
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
                        'Este usuário é um Administrador do sistema. Ele possui acesso total irrestrito a todos os recursos e suas permissões não podem ser customizadas.'
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

                return Card(
                  margin: const EdgeInsets.only(bottom: Sizes.p16),
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
                        BaseText.bodyMedium(
                          resourceLabel,
                          fontWeight: FontWeight.bold,
                        ),
                        const Divider(height: Sizes.p20),
                        Column(
                          children: PermissionAction.values.map((action) {
                            final key = '${resource.code}.${action.code}';
                            final currentValue =
                                _localOverrides[key] ?? 'inherit';
                            final inheritedValue = _isGroupActionEnabled(
                              resource,
                              action,
                            );

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

                            return Padding(
                              padding: const EdgeInsets.only(bottom: Sizes.p12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BaseText(actionLabel),
                                  const SizedBox(height: Sizes.p8),
                                  _buildThreeStateToggle(
                                    currentValue: currentValue,
                                    inheritedValue: inheritedValue,
                                    onChanged: widget.user.isAdmin
                                        ? (val) {}
                                        : (value) => _setOverride(
                                            resource,
                                            action,
                                            value,
                                          ),
                                    context: context,
                                  ),
                                ],
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
