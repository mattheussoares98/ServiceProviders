import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_parameter_request_model.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';

import '../../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  group('CompanyParameterRequestModel', () {
    final tEntity = UserFactory.makeCompanyParameterEntity();

    test('should be a subclass of CompanyParameterEntity', () {
      final model = CompanyParameterRequestModel.fromEntity(tEntity);
      expect(model, isA<CompanyParameterEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final model = CompanyParameterRequestModel.fromEntity(tEntity);
      final json = model.toJson();
      final modelFromJson = CompanyParameterRequestModel.fromJson(json);
      final resultEntity = modelFromJson.toEntity();

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
    });
  });
}
