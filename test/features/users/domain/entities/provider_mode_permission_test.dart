import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/has_permission_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  const updateWorkOrders = ActionPermission.resource(
    resourceType: ResourceType.workOrders,
    permissionAction: PermissionAction.update,
  );
  const deleteWorkOrders = ActionPermission.resource(
    resourceType: ResourceType.workOrders,
    permissionAction: PermissionAction.delete,
  );
  const readWorkOrders = ActionPermission.resource(
    resourceType: ResourceType.workOrders,
    permissionAction: PermissionAction.read,
  );
  const manageUsers = ActionPermission.resource(
    resourceType: ResourceType.users,
    permissionAction: PermissionAction.update,
  );
  const managePendingRequests = ActionPermission.workOrderSubAction(
    WorkOrderSubAction.managePendingRequests,
  );
  const changeStatus = ActionPermission.workOrderSubAction(
    WorkOrderSubAction.changeStatus,
  );

  group('providerModeAllows', () {
    test('allows reading, creating, updating and executing assigned work orders', () {
      expect(providerModeAllows(readWorkOrders), isTrue);
      expect(
        providerModeAllows(
          const ActionPermission.resource(
            resourceType: ResourceType.workOrders,
            permissionAction: PermissionAction.create,
          ),
        ),
        isTrue,
      );
      expect(providerModeAllows(updateWorkOrders), isTrue);
      expect(providerModeAllows(changeStatus), isTrue);
    });

    test('denies deleting, reassigning and approving work orders', () {
      expect(providerModeAllows(deleteWorkOrders), isFalse);
      expect(providerModeAllows(managePendingRequests), isFalse);
      expect(
        providerModeAllows(
          const ActionPermission.workOrderSubAction(
            WorkOrderSubAction.reassign,
          ),
        ),
        isFalse,
      );
      expect(
        providerModeAllows(
          const ActionPermission.workOrderSubAction(
            WorkOrderSubAction.deleteObservation,
          ),
        ),
        isFalse,
      );
    });

    test('denies the administration surfaces of the contracting company', () {
      expect(providerModeAllows(manageUsers), isFalse);
      expect(
        providerModeAllows(
          const ActionPermission.resource(
            resourceType: ResourceType.serviceProviders,
            permissionAction: PermissionAction.read,
          ),
        ),
        isFalse,
      );
      for (final resource in ResourceType.values) {
        for (final action in [
          PermissionAction.create,
          PermissionAction.update,
          PermissionAction.delete,
        ]) {
          final isAllowedAction =
              (action == PermissionAction.create &&
                  (resource == ResourceType.attachments ||
                      resource == ResourceType.workOrders)) ||
              (action == PermissionAction.update &&
                  resource == ResourceType.workOrders);
          if (isAllowedAction) continue;
          expect(
            providerModeAllows(
              ActionPermission.resource(
                resourceType: resource,
                permissionAction: action,
              ),
            ),
            isFalse,
            reason: '${resource.code}.${action.code} must be denied',
          );
        }
      }
    });
  });

  group('HasPermissionUseCase.evaluatePermission in provider mode', () {
    test('an internal admin does not inherit admin rights', () {
      final admin = EntityFactory.makeUserProfileEntity().copyWith(
        isAdmin: true,
      );

      expect(
        HasPermissionUseCase.evaluatePermission(
          permission: managePendingRequests,
          user: admin,
          permissionGroups: const [],
          appMode: AppMode.provider,
        ),
        isFalse,
      );
      expect(
        HasPermissionUseCase.evaluatePermission(
          permission: deleteWorkOrders,
          user: admin,
          permissionGroups: const [],
          appMode: AppMode.provider,
        ),
        isFalse,
      );
      expect(
        HasPermissionUseCase.evaluatePermission(
          permission: managePendingRequests,
          user: admin,
          permissionGroups: const [],
        ),
        isTrue,
        reason: 'internal mode keeps the admin bypass',
      );
    });

    test('a provider-only user can still execute work orders', () {
      final providerOnly = EntityFactory.makeUserProfileEntity().copyWith(
        annulCompanyId: true,
        annulPermissionGroupId: true,
      );

      expect(
        HasPermissionUseCase.evaluatePermission(
          permission: changeStatus,
          user: providerOnly,
          permissionGroups: const [],
          appMode: AppMode.provider,
        ),
        isTrue,
      );
      expect(
        HasPermissionUseCase.evaluatePermission(
          permission: changeStatus,
          user: providerOnly,
          permissionGroups: const [],
        ),
        isFalse,
        reason: 'internal RBAC grants nothing to a user without a group',
      );
    });
  });
}
