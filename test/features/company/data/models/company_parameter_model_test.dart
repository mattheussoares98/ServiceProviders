import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  group('CompanyParameterModel', () {
    final tEntity = EntityFactory.makeCompanyParameterEntity();

    test('should be a subclass of CompanyParameterEntity', () {
      final model = CompanyParameterModel.fromEntity(tEntity);
      expect(model, isA<CompanyParameterEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final model = CompanyParameterModel.fromEntity(tEntity);
      final json = model.toJson();
      final modelFromJson = CompanyParameterModel.fromJson(json);
      final resultEntity = modelFromJson.toEntity();

      expect(resultEntity.id, tEntity.id);
      expect(resultEntity.companyId, tEntity.companyId);
      expect(resultEntity.advanceWarningMinutes, tEntity.advanceWarningMinutes);
      expect(
        resultEntity.advanceWarningGroupIds,
        tEntity.advanceWarningGroupIds,
      );
      expect(
        resultEntity.delayedNotificationIntervalMinutes,
        tEntity.delayedNotificationIntervalMinutes,
      );
      expect(resultEntity.escalationGroupIds, tEntity.escalationGroupIds);
      expect(resultEntity.maxOfflineDurationHours, tEntity.maxOfflineDurationHours);
      expect(resultEntity.maxImageSizeMb, tEntity.maxImageSizeMb);
    });
  });
}
