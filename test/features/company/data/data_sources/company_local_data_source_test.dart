import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_local_data_source.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_parameter_response_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_response_model.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

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

  final tCompanyId = faker.guid.guid();
  final tCompanyModel = CompanyResponseModel(
    id: tCompanyId,
    name: faker.company.name(),
    cnpj: '12345678000199', // CNPJ is a validated format
    logoUrl: faker.internet.httpsUrl(),
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tCompanyParameterModel = CompanyParameterResponseModel(
    id: faker.guid.guid(),
    companyId: tCompanyId,
    maxOfflineDurationHours: faker.randomGenerator.integer(24, min: 1),
    maxOfflinePendingRequests: faker.randomGenerator.integer(50, min: 5),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
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
        expect(getResult, isA<SuccessState<CompanyResponseModel>>());
        expect(getResult.data, isNotNull);
        expect(getResult.data!.id, tCompanyModel.id);
        expect(getResult.data!.name, tCompanyModel.name);
        expect(getResult.data!.cnpj, tCompanyModel.cnpj);
        expect(getResult.data!.logoUrl, tCompanyModel.logoUrl);
        expect(getResult.data!.isActive, tCompanyModel.isActive);
      });

      test('should return FailureState when company is not found', () async {
        final getResult = await dataSource.getCompany('non-existent-id');
        expect(getResult, isA<FailureState<CompanyResponseModel>>());
      });
    });

    group('saveCompanyParameters and getCompanyParameters', () {
      test('should save company parameters and successfully retrieve them', () async {
        // Need to save the company first due to foreign key constraints
        await dataSource.saveCompany(tCompanyModel);

        // Act: Save parameters
        final saveResult = await dataSource.saveCompanyParameters(tCompanyParameterModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Retrieve parameters
        final getResult = await dataSource.getCompanyParameters(tCompanyModel.id);

        // Assert Retrieve
        expect(getResult, isA<SuccessState<CompanyParameterResponseModel>>());
        expect(getResult.data, isNotNull);
        expect(getResult.data!.id, tCompanyParameterModel.id);
        expect(getResult.data!.companyId, tCompanyParameterModel.companyId);
        expect(getResult.data!.maxOfflineDurationHours, tCompanyParameterModel.maxOfflineDurationHours);
        expect(getResult.data!.maxOfflinePendingRequests, tCompanyParameterModel.maxOfflinePendingRequests);
      });

      test('should return FailureState when parameters are not found', () async {
        final getResult = await dataSource.getCompanyParameters('non-existent-company-id');
        expect(getResult, isA<FailureState<CompanyParameterResponseModel>>());
      });
    });
  });
}
