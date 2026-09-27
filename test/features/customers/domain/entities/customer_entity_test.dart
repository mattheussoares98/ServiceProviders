import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';

import '../../../../../testing/mocks/factories/customer_factory.dart';

void main() {
  group('CustomerEntity', () {
    test('should support value equality', () {
      final customer1 = CustomerFactory.makeCustomerEntity();
      final customer2 = customer1.copyWith();

      expect(customer1, equals(customer2));
    });

    group('documentType', () {
      test('should return DocumentType.cpf when document has 11 digits', () {
        final customer = CustomerFactory.makeCustomerEntity().copyWith(
          document: '123.456.789-01',
        );

        expect(customer.documentType, equals(DocumentType.cpf));
      });

      test('should return DocumentType.cnpj when document has 14 digits', () {
        final customer = CustomerFactory.makeCustomerEntity().copyWith(
          document: '12.345.678/0001-90',
        );

        expect(customer.documentType, equals(DocumentType.cnpj));
      });

      test('should return null when document is null', () {
        final customer = CustomerFactory.makeCustomerEntity().copyWith(
          annulDocument: true,
        );

        expect(customer.document, isNull);
        expect(customer.documentType, isNull);
      });

      test('should return null when digits count is not 11 or 14', () {
        final customer = CustomerFactory.makeCustomerEntity().copyWith(
          document: '12345678',
        );

        expect(customer.documentType, isNull);
      });
    });

    group('copyWith', () {
      test('should update specified fields', () {
        final original = CustomerFactory.makeCustomerEntity();
        final updated = original.copyWith(
          name: 'Updated Name',
          city: 'Updated City',
          isActive: false,
        );

        expect(updated.name, equals('Updated Name'));
        expect(updated.city, equals('Updated City'));
        expect(updated.isActive, isFalse);
        expect(updated.id, equals(original.id));
      });

      test('should annul nullable fields when annul flag is true', () {
        final original = CustomerFactory.makeCustomerEntity().copyWith(
          deletedAt: DateTime.utc(2026),
        );

        final updated = original.copyWith(
          annulDocument: true,
          annulContactName: true,
          annulContactEmail: true,
          annulContactPhone: true,
          annulAddress: true,
          annulNumber: true,
          annulComplement: true,
          annulNeighborhood: true,
          annulCity: true,
          annulState: true,
          annulPostalCode: true,
          annulNotes: true,
          annulDeletedAt: true,
        );

        expect(updated.document, isNull);
        expect(updated.contactName, isNull);
        expect(updated.contactEmail, isNull);
        expect(updated.contactPhone, isNull);
        expect(updated.address, isNull);
        expect(updated.number, isNull);
        expect(updated.complement, isNull);
        expect(updated.neighborhood, isNull);
        expect(updated.city, isNull);
        expect(updated.state, isNull);
        expect(updated.postalCode, isNull);
        expect(updated.notes, isNull);
        expect(updated.deletedAt, isNull);
      });
    });
  });
}
