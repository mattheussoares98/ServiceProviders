import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makePermissionGroupEntity();

  group('PermissionGroupResponseModel', () {
    test('should be a subclass of PermissionGroupEntity', () {
      final model = PermissionGroupResponseModel.fromEntity(tEntity);
      expect(model, isA<PermissionGroupEntity>());
    });

    test('should serialize to JSON correctly on toJson', () {
      final model = PermissionGroupResponseModel.fromEntity(tEntity);
      final json = model.toJson();

      expect(json['id'], tEntity.id);
      expect(json['company_id'], tEntity.companyId);
      expect(json['name'], tEntity.name);

      // Verify explicit resource.action format is present
      final permissions = json['permissions'] as List<dynamic>;
      expect(permissions, contains('work_orders.create'));
      expect(permissions, contains('work_orders.update'));
      expect(permissions, contains('attachments.create'));
    });

    test('should deserialize generic actions correctly on fromJson', () {
      final json = {
        'id': '123',
        'company_id': '456',
        'name': 'Admin Group',
        'permissions': ['work_orders.create', 'work_orders.read'],
      };

      final result = PermissionGroupResponseModel.fromJson(json);

      expect(result.id, '123');
      expect(result.companyId, '456');
      expect(result.name, 'Admin Group');
      expect(result.permissions, hasLength(1));

      final actions = result.permissions[ResourceType.workOrders]!;
      expect(actions, contains(PermissionAction.create));
      expect(actions, contains(PermissionAction.read));
      expect(actions, isNot(contains(PermissionAction.update)));
    });

    test('should expand resource wildcard .* correctly on fromJson', () {
      final json = {
        'id': '123',
        'company_id': '456',
        'name': 'Admin Group',
        'permissions': ['work_orders.*'],
      };

      final result = PermissionGroupResponseModel.fromJson(json);
      expect(result.permissions, hasLength(1));

      final actions = result.permissions[ResourceType.workOrders]!;
      expect(actions, contains(PermissionAction.create));
      expect(actions, contains(PermissionAction.read));
      expect(actions, contains(PermissionAction.update));
      expect(actions, contains(PermissionAction.delete));
    });

    test('should expand global wildcard * correctly on fromJson', () {
      final json = {
        'id': '123',
        'company_id': '456',
        'name': 'Admin Group',
        'permissions': ['*'],
      };

      final result = PermissionGroupResponseModel.fromJson(json);
      expect(result.permissions, hasLength(ResourceType.values.length));

      for (final res in ResourceType.values) {
        final actions = result.permissions[res]!;
        expect(actions, contains(PermissionAction.create));
        expect(actions, contains(PermissionAction.read));
        expect(actions, contains(PermissionAction.update));
        expect(actions, contains(PermissionAction.delete));
      }
    });
  });
}
