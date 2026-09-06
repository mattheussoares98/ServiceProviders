import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';

import '../../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  final tEntity = UserFactory.makeCompanyEntity();

  group('CompanyRequestModel', () {
    test('should be a subclass of CompanyEntity', () {
      final model = CompanyRequestModel.fromEntity(tEntity);
      expect(model, isA<CompanyEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = CompanyRequestModel.fromEntity(tEntity);
      final expected = CompanyRequestModel.fromEntity(tEntity);
      expect(model, expected);
    });

    test('should return a valid model fromJson', () {
      final responseModel = CompanyModel.fromEntity(tEntity);

      final result = CompanyRequestModel.fromJson(responseModel.toJson());

      expect(result, CompanyRequestModel.fromEntity(tEntity));
    });

    test('should omit database-generated columns on toJson', () {
      final model = CompanyRequestModel.fromEntity(tEntity);

      final result = model.toJson();

      expect(result.containsKey('id'), isFalse);
      expect(result.containsKey('created_at'), isFalse);
      expect(result.containsKey('updated_at'), isFalse);
      expect(result['name'], model.name);
      expect(result['cnpj'], model.cnpj);
      expect(result['logo_url'], model.logoUrl);
      expect(result['is_active'], model.isActive);
    });

    test('should convert to a CompanyEntity correctly on toEntity', () {
      final model = CompanyRequestModel.fromEntity(tEntity);

      final entity = model.toEntity();

      expect(entity, tEntity);
    });
  });
}
