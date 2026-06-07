import 'package:clean_architecture/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:clean_architecture/features/users/domain/entities/permission.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final List<dynamic> permissions = json['permissions'] as List<dynamic>;
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

      final firstPerm = result.permissions.first;
      expect(firstPerm.resource, ResourceType.workOrders);
      expect(firstPerm.canCreate, isTrue);
      expect(firstPerm.canRead, isTrue);
      expect(firstPerm.canUpdate, isFalse);
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

      final firstPerm = result.permissions.first;
      expect(firstPerm.resource, ResourceType.workOrders);
      expect(firstPerm.canCreate, isTrue);
      expect(firstPerm.canRead, isTrue);
      expect(firstPerm.canUpdate, isTrue);
      expect(firstPerm.canDelete, isTrue);
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
        final perm = result.permissions.firstWhere((p) => p.resource == res);
        expect(perm.canCreate, isTrue);
        expect(perm.canRead, isTrue);
        expect(perm.canUpdate, isTrue);
        expect(perm.canDelete, isTrue);
      }
    });
  });
}
