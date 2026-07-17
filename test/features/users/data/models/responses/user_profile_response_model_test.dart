import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeUserProfileEntity();

  group('UserProfileResponseModel', () {
    test('should be a subclass of UserProfileEntity', () {
      final model = UserProfileResponseModel.fromEntity(tEntity);
      expect(model, isA<UserProfileEntity>());
    });

    test(
      'should serialize to JSON with correct flat format overrides on toJson',
      () {
        final model = UserProfileResponseModel.fromEntity(
          tEntity.copyWith(
            workOrders: const UserWorkOrdersPermissionOverrideEntity(
              readScope: WorkOrderReadScope.assigned,
              create: true,
              updateScope: WorkOrderUpdateScope.own,
              delete: false,
              changeStatus: true,
            ),
          ),
        );

        final json = model.toJson();

        expect(json['id'], tEntity.id);
        expect(json['company_id'], tEntity.companyId);
        expect(json['name'], tEntity.name);

        final permissions = json['permissions'] as Map<String, dynamic>;
        expect(permissions['work_orders.read_scope'], 'assigned');
        expect(permissions['work_orders.create'], true);
        expect(permissions['work_orders.update_scope'], 'own');
        expect(permissions['work_orders.delete'], false);
        expect(permissions['work_orders.change_status'], true);
      },
    );

    test(
      'should deserialize generic actions and scopes correctly on fromJson',
      () {
        final json = {
          'id': 'user-123',
          'company_id': 'company-456',
          'name': 'John Doe',
          'email': 'john@test.com',
          'is_active': true,
          'is_admin': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'permissions': {
            'attachments.create': true,
            'attachments.delete': false,
            'work_orders.read_scope': 'assigned',
            'work_orders.update_scope': 'own',
            'work_orders.change_status': true,
          },
        };

        final result = UserProfileResponseModel.fromJson(json);

        expect(result.id, 'user-123');
        expect(result.name, 'John Doe');

        // Standard permission override check
        expect(
          result.permissions[ResourceType.attachments]?[PermissionAction
              .create],
          true,
        );
        expect(
          result.permissions[ResourceType.attachments]?[PermissionAction
              .delete],
          false,
        );
        expect(
          result.permissions[ResourceType.attachments]?[PermissionAction
              .update],
          isNull,
        );

        // Scoped work orders permission override check
        expect(
          result.workOrdersPermissionOverrides.readScope,
          WorkOrderReadScope.assigned,
        );
        expect(
          result.workOrdersPermissionOverrides.updateScope,
          WorkOrderUpdateScope.own,
        );
        expect(result.workOrdersPermissionOverrides.changeStatus, true);
        expect(result.workOrdersPermissionOverrides.create, isNull);
      },
    );
  });
}
