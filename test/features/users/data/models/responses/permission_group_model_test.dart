import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makePermissionGroupEntity();

  group('PermissionGroupModel', () {
    test('should be a subclass of PermissionGroupEntity', () {
      final model = PermissionGroupModel.fromEntity(tEntity);
      expect(model, isA<PermissionGroupEntity>());
    });

    test('should serialize to JSON correctly on toJson', () {
      final model = PermissionGroupModel.fromEntity(tEntity);
      final json = model.toJson();

      expect(json['id'], tEntity.id);
      expect(json['company_id'], tEntity.companyId);
      expect(json['name'], tEntity.name);

      // Verify explicit resource.action flat map structure
      final permissions = json['permissions'] as Map<String, dynamic>;
      expect(permissions['attachments.create'], true);
      expect(permissions['work_orders.read_scope'], 'assigned');
    });

    test('should deserialize flat map correctly on fromJson', () {
      final json = {
        'id': '123',
        'company_id': '456',
        'name': 'Admin Group',
        'permissions': {
          'attachments.create': true,
          'attachments.read': true,
          'work_orders.read_scope': 'all',
          'work_orders.update_scope': 'assigned',
        },
      };

      final result = PermissionGroupModel.fromJson(json);

      expect(result.id, '123');
      expect(result.companyId, '456');
      expect(result.name, 'Admin Group');

      final actions = result.permissions[ResourceType.attachments]!;
      expect(actions, contains(PermissionAction.create));
      expect(actions, contains(PermissionAction.read));
      expect(actions, isNot(contains(PermissionAction.update)));

      expect(result.workOrders.readScope, WorkOrderReadScope.all);
      expect(result.workOrders.updateScope, WorkOrderUpdateScope.assigned);
    });

    test('should expand global wildcard * correctly on fromJson', () {
      final json = {
        'id': '123',
        'company_id': '456',
        'name': 'Admin Group',
        'permissions': {'*': true},
      };

      final result = PermissionGroupModel.fromJson(json);
      expect(
        result.permissions,
        hasLength(ResourceType.values.length - 1),
      ); // all except workOrders

      for (final res in ResourceType.values) {
        if (res == ResourceType.workOrders) continue;
        final actions = result.permissions[res]!;
        expect(actions, contains(PermissionAction.create));
        expect(actions, contains(PermissionAction.update));
        expect(actions, contains(PermissionAction.delete));
      }
      expect(result.workOrders.readScope, WorkOrderReadScope.all);
      expect(result.workOrders.updateScope, WorkOrderUpdateScope.all);
    });

    test(
      'should preserve wildcard * and custom resource families on round-trip via fromEntity',
      () {
        final json = {
          'id': '123',
          'company_id': '456',
          'name': 'Administrador',
          'permissions': {
            '*': true,
            'checklists.read': true,
            'reports.read': true,
          },
        };

        final fromDbModel = PermissionGroupModel.fromJson(json);
        final entity = fromDbModel.toEntity();
        final roundTrippedModel = PermissionGroupModel.fromEntity(entity);
        final serializedJson = roundTrippedModel.toJson();

        final permissions =
            serializedJson['permissions'] as Map<String, dynamic>;
        expect(permissions['*'], true);
        expect(permissions['checklists.read'], true);
        expect(permissions['reports.read'], true);
      },
    );
  });
}
