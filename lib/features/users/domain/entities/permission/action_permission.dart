import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';

class ActionPermission extends Equatable {
  const ActionPermission({required this.resource, required this.action});

  final ResourceType resource;
  final PermissionAction action;

  @override
  List<Object?> get props => [resource, action];
}
