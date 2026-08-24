import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/app_database.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_local_data_source.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late CompanyLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = CompanyLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  final tCompanyEntity = EntityFactory.makeCompanyEntity();
  final tCompanyModel = CompanyModel.fromEntity(tCompanyEntity);

  final tCompanyParameterEntity = EntityFactory.makeCompanyParameterEntity()
      .copyWith(companyId: tCompanyModel.id);
  final tCompanyParameterModel = CompanyParameterModel.fromEntity(
    tCompanyParameterEntity,
  );

  group('CompanyLocalDataSourceImpl', () {
    group('saveCompany and getCompany', () {
      test('should save a company and successfully retrieve it', () async {
        // Act: Save the company
        final saveResult = await dataSource.saveCompany(tCompanyModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Retrieve the company
        final getResult = await dataSource.getCompany(tCompanyModel.id);

        // Assert Retrieve
        expect(getResult, isA<SuccessState<CompanyModel>>());
        expect(getResult.data, isNotNull);
        expect(getResult.data!.id, tCompanyModel.id);
        expect(getResult.data!.name, tCompanyModel.name);
        expect(getResult.data!.cnpj, tCompanyModel.cnpj);
        expect(getResult.data!.logoUrl, tCompanyModel.logoUrl);
        expect(getResult.data!.isActive, tCompanyModel.isActive);
      });

      test('should return FailureState when company is not found', () async {
        final getResult = await dataSource.getCompany('non-existent-id');
        expect(getResult, isA<FailureState<CompanyModel>>());
      });
    });

    group('saveCompanyParameters and getCompanyParameters', () {
      test(
        'should save company parameters and successfully retrieve them',
        () async {
          // Need to save the company first due to foreign key constraints
          await dataSource.saveCompany(tCompanyModel);

          // Act: Save parameters
          final saveResult = await dataSource.saveCompanyParameters(
            tCompanyParameterModel,
          );

          // Assert Save
          expect(saveResult, isA<SuccessState<bool>>());
          expect(saveResult.data, isTrue);

          // Act: Retrieve parameters
          final getResult = await dataSource.getCompanyParameters(
            tCompanyModel.id,
          );

          // Assert Retrieve
          expect(getResult, isA<SuccessState<CompanyParameterModel>>());
          expect(getResult.data, isNotNull);
          expect(getResult.data!.id, tCompanyParameterModel.id);
          expect(getResult.data!.companyId, tCompanyParameterModel.companyId);
          expect(
            getResult.data!.maxOfflineDurationHours,
            tCompanyParameterModel.maxOfflineDurationHours,
          );
          expect(
            getResult.data!.maxOfflinePendingRequests,
            tCompanyParameterModel.maxOfflinePendingRequests,
          );
          expect(
            getResult.data!.offlineAlertThrottleFrequency,
            tCompanyParameterModel.offlineAlertThrottleFrequency,
          );
          expect(
            getResult.data!.maxImageSizeMb,
            tCompanyParameterModel.maxImageSizeMb,
          );
          expect(
            getResult.data!.maxVideoSizeMb,
            tCompanyParameterModel.maxVideoSizeMb,
          );
          expect(
            getResult.data!.maxPdfSizeMb,
            tCompanyParameterModel.maxPdfSizeMb,
          );
          expect(
            getResult.data!.maxDocumentSizeMb,
            tCompanyParameterModel.maxDocumentSizeMb,
          );
          expect(
            getResult.data!.sandboxQuotaMb,
            tCompanyParameterModel.sandboxQuotaMb,
          );
          expect(
            getResult.data!.maxSyncAttempts,
            tCompanyParameterModel.maxSyncAttempts,
          );
          expect(
            getResult.data!.inviteExpiryHours,
            tCompanyParameterModel.inviteExpiryHours,
          );
        },
      );

      test(
        'should return FailureState when parameters are not found',
        () async {
          final getResult = await dataSource.getCompanyParameters(
            'non-existent-company-id',
          );
          expect(getResult, isA<FailureState<CompanyParameterModel>>());
        },
      );
    });
  });
}

