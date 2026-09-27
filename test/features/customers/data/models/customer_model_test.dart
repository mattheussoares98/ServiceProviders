import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/customers/data/models/responses/customer_model.dart';
import 'package:o_jogo_da_obra/features/customers/domain/entities/customer_entity.dart';

import '../../../../../testing/mocks/factories/customer_factory.dart';

void main() {
  final tEntity = CustomerFactory.makeCustomerEntity();

  group('CustomerModel', () {
    test('should be a subclass of CustomerEntity', () {
      final model = CustomerModel.fromEntity(tEntity);
      expect(model, isA<CustomerEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = CustomerModel.fromEntity(tEntity);
      final expected = CustomerModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = CustomerModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = CustomerModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = CustomerModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, equals(expectedJson));
    });

    test('should convert to a CustomerEntity correctly on toEntity', () {
      final model = CustomerModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, equals(tEntity));
    });

    test('should handle nullable and default fields in fromJson', () {
      final json = <String, dynamic>{
        'id': 'cust-1',
        'company_id': 'comp-1',
        'name': 'Client A',
      };

      final model = CustomerModel.fromJson(json);

      expect(model.id, equals('cust-1'));
      expect(model.companyId, equals('comp-1'));
      expect(model.name, equals('Client A'));
      expect(model.document, isNull);
      expect(model.isActive, isTrue);
      expect(model.deletedAt, isNull);
    });
  });
}
