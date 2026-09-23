import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/plan_type.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/work_type.dart';

import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  final tEntity = UserFactory.makeCompanyEntity();

  group('CompanyModel', () {
    test('should be a subclass of CompanyEntity', () {
      final model = CompanyModel.fromEntity(tEntity);
      expect(model, isA<CompanyEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final model = CompanyModel.fromEntity(tEntity);
      final json = model.toJson();
      final modelFromJson = CompanyModel.fromJson(json);
      final resultEntity = modelFromJson.toEntity();

      expect(resultEntity.id, tEntity.id);
      expect(resultEntity.name, tEntity.name);
      expect(resultEntity.cnpj, tEntity.cnpj);
      expect(resultEntity.logoUrl, tEntity.logoUrl);
      expect(resultEntity.isActive, tEntity.isActive);
      expect(resultEntity.planType, tEntity.planType);
      expect(resultEntity.workType, tEntity.workType);
    });

    test('should default planType and workType when null in fromJson', () {
      final json = {
        'id': 'c1',
        'name': 'Test Co',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final model = CompanyModel.fromJson(json);

      expect(model.planType, PlanType.free);
      expect(model.workType, WorkType.internalOnly);
    });
  });
}
