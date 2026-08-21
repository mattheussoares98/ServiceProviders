import 'package:o_jogo_da_obra/features/users/domain/entities/permission/action_permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission_action.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/resource_type.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/work_order_sub_action.dart';

/// Capabilities of a user acting in `AppMode.provider`.
///
/// Provider mode is a distinct application: the internal RBAC of the user's own
/// employer (permission groups, per-user overrides, the `isAdmin` flag) says
/// nothing about what they may do inside a *contracting* company. Evaluating it
/// there would let an admin of their own company act as an admin of every client
/// they serve. This fixed set mirrors what the provider RLS branches actually
/// grant (`20260820120000_add_provider_access_to_work_orders.sql`): read and
/// execute the work orders assigned to them, plus attachments and observations
/// on those orders. Approval, reassignment and every registry stay with the
/// contracting company.
bool providerModeAllows(ActionPermission permission) {
  return switch (permission) {
    ResourceActionPermission(
      resourceType: final resource,
      permissionAction: final action,
    ) =>
      _allowsResource(resource, action),
    WorkOrderSubActionPermission(:final subAction) => switch (subAction) {
      // Providers execute the work: start, pause request, resume, completion request.
      WorkOrderSubAction.changeStatus => true,
      // Approving requests, reassigning and erasing history belong to the client.
      WorkOrderSubAction.managePendingRequests => false,
      WorkOrderSubAction.reassign => false,
      WorkOrderSubAction.deleteObservation => false,
    },
  };
}

bool _allowsResource(ResourceType resource, PermissionAction action) {
  return switch (resource) {
    // Opening and editing a work order for a client is allowed (field-level
    // restrictions are handled in UI); deleting stays with the contracting company.
    ResourceType.workOrders =>
      action == PermissionAction.read ||
          action == PermissionAction.create ||
          action == PermissionAction.update,
    ResourceType.attachments =>
      action == PermissionAction.read || action == PermissionAction.create,
    // Read-only lookups the work order details page renders as labels.
    ResourceType.assets ||
    ResourceType.categories ||
    ResourceType.locations ||
    ResourceType.sectors ||
    ResourceType.slaPolicies => action == PermissionAction.read,
    // Administration surfaces of the contracting company.
    ResourceType.serviceProviders || ResourceType.users => false,
  };
}
