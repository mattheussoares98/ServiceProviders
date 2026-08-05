import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_response_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  group('ServiceProviderCompanyResponseModel', () {
    final tEntity = EntityFactory.makeServiceProviderCompanyEntity();

    test('should be a subclass of ServiceProviderCompanyEntity', () {
      final responseModel = ServiceProviderCompanyResponseModel.fromEntity(
        tEntity,
      );
      expect(responseModel, isA<ServiceProviderCompanyEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final responseModel = ServiceProviderCompanyResponseModel.fromEntity(
        tEntity,
      );
      final responseJson = responseModel.toJson();
      final responseModelFromJson =
          ServiceProviderCompanyResponseModel.fromJson(responseJson);

      final resultEntity = responseModelFromJson.toEntity();
      expect(resultEntity.id, tEntity.id);
      expect(resultEntity.companyId, tEntity.companyId);
      expect(resultEntity.name, tEntity.name);
      expect(resultEntity.document, tEntity.document);
      expect(resultEntity.documentType, tEntity.documentType);
      expect(resultEntity.contactEmail, tEntity.contactEmail);
      expect(resultEntity.contactPhone, tEntity.contactPhone);
      expect(resultEntity.isActive, tEntity.isActive);
    });
  });

  group('ServiceProviderProfileResponseModel', () {
    final tEntity = EntityFactory.makeServiceProviderProfileEntity();

    test('should be a subclass of ServiceProviderProfileEntity', () {
      final responseModel = ServiceProviderProfileResponseModel.fromEntity(
        tEntity,
      );
      expect(responseModel, isA<ServiceProviderProfileEntity>());
    });

    test('should map fromEntity, toJson, fromJson, and toEntity correctly', () {
      final responseModel = ServiceProviderProfileResponseModel.fromEntity(
        tEntity,
      );
      final responseJson = responseModel.toJson();
      final responseModelFromJson =
          ServiceProviderProfileResponseModel.fromJson(responseJson);

      final resultEntity = responseModelFromJson.toEntity();
      expect(resultEntity.id, tEntity.id);
      expect(resultEntity.authUserId, tEntity.authUserId);
      expect(resultEntity.serviceProviderCompanyId, tEntity.serviceProviderCompanyId);
      expect(resultEntity.name, tEntity.name);
      expect(resultEntity.email, tEntity.email);
      expect(resultEntity.phone, tEntity.phone);
      expect(resultEntity.isActive, tEntity.isActive);
    });
  });
}
