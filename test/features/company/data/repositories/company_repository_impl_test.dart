import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_parameter_response_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_response_model.dart';
import 'package:clean_architecture/features/company/data/repositories/company_repository_impl.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/entities/company_parameter_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockCompanyRemoteDataSource mockRemoteDataSource;
  late MockCompanyLocalDataSource mockLocalDataSource;
  late CompanyRepositoryImpl repository;

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockCompanyRemoteDataSource();
    mockLocalDataSource = MockCompanyLocalDataSource();
    repository = CompanyRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );

    registerFallbackValue(
      CompanyResponseModel(
        id: '',
        name: '',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      CompanyParameterResponseModel(
        id: '',
        companyId: '',
        maxOfflineDurationHours: 2,
        maxOfflinePendingRequests: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  final tCompanyId = faker.guid.guid();
  final tCompanyModel = CompanyResponseModel(
    id: tCompanyId,
    name: faker.company.name(),
    cnpj: '12345678000199',
    logoUrl: faker.internet.httpsUrl(),
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tCompanyParameterModel = CompanyParameterResponseModel(
    id: faker.guid.guid(),
    companyId: tCompanyId,
    maxOfflineDurationHours: 4,
    maxOfflinePendingRequests: 20,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CompanyRepositoryImpl', () {
    group('getCompany', () {
      test('should call localDataSource.getCompany and return mapped entity on success', () async {
        // Arrange
        when(() => mockLocalDataSource.getCompany(any()))
            .thenAnswer((_) async => SuccessState(data: tCompanyModel));

        // Act
        final result = await repository.getCompany(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<CompanyEntity>>());
        expect(result.data, tCompanyModel.toEntity());
        verify(() => mockLocalDataSource.getCompany(tCompanyId)).called(1);
      });

      test('should return FailureState when localDataSource.getCompany fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getCompany(any()))
            .thenAnswer((_) async => FailureState<CompanyResponseModel>(message: 'Error'));

        // Act
        final result = await repository.getCompany(tCompanyId);

        // Assert
        expect(result, isA<FailureState<CompanyEntity>>());
        verify(() => mockLocalDataSource.getCompany(tCompanyId)).called(1);
      });
    });

    group('getCompanyParameters', () {
      test('should call localDataSource.getCompanyParameters and return mapped entity on success', () async {
        // Arrange
        when(() => mockLocalDataSource.getCompanyParameters(any()))
            .thenAnswer((_) async => SuccessState(data: tCompanyParameterModel));

        // Act
        final result = await repository.getCompanyParameters(tCompanyId);

        // Assert
        expect(result, isA<SuccessState<CompanyParameterEntity>>());
        expect(result.data, tCompanyParameterModel.toEntity());
        verify(() => mockLocalDataSource.getCompanyParameters(tCompanyId)).called(1);
      });

      test('should return FailureState when localDataSource.getCompanyParameters fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getCompanyParameters(any()))
            .thenAnswer((_) async => FailureState<CompanyParameterResponseModel>(message: 'Error'));

        // Act
        final result = await repository.getCompanyParameters(tCompanyId);

        // Assert
        expect(result, isA<FailureState<CompanyParameterEntity>>());
        verify(() => mockLocalDataSource.getCompanyParameters(tCompanyId)).called(1);
      });
    });

    group('saveCompany', () {
      test('should call localDataSource.saveCompany and return true on success', () async {
        // Arrange
        when(() => mockLocalDataSource.saveCompany(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.saveCompany(tCompanyModel.toEntity());

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.saveCompany(any())).called(1);
      });
    });

    group('saveCompanyParameters', () {
      test('should call localDataSource.saveCompanyParameters and return true on success', () async {
        // Arrange
        when(() => mockLocalDataSource.saveCompanyParameters(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.saveCompanyParameters(tCompanyParameterModel.toEntity());

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.saveCompanyParameters(any())).called(1);
      });
    });
  });
}
