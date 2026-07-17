import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';

class ResourcePermissionEntity extends Equatable {
  const ResourcePermissionEntity({
    required this.resource,
    required this.actions,
  });

  final ResourceType resource;
  final Set<PermissionAction> actions;

  bool get canCreate => actions.contains(PermissionAction.create);
  bool get canRead => actions.contains(PermissionAction.read);
  bool get canUpdate => actions.contains(PermissionAction.update);
  bool get canDelete => actions.contains(PermissionAction.delete);

  @override
  List<Object?> get props => [resource, actions];
}
