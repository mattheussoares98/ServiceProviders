import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/company/data/models/requests/company_request_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_parameter_model.dart';
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
      CompanyModel(
        id: '',
        name: '',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      CompanyParameterModel(
        id: '',
        companyId: '',
        maxOfflineDurationHours: 2,
        maxOfflinePendingRequests: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      CompanyRequestModel(
        id: '',
        name: '',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  final tCompanyId = faker.guid.guid();
  final tCompanyModel = CompanyModel(
    id: tCompanyId,
    name: faker.company.name(),
    cnpj: '12345678000199',
    logoUrl: faker.internet.httpsUrl(),
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final tCompanyParameterModel = CompanyParameterModel(
    id: faker.guid.guid(),
    companyId: tCompanyId,
    maxOfflineDurationHours: 4,
    maxOfflinePendingRequests: 20,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('CompanyRepositoryImpl', () {
    group('createCompany', () {
      test(
        'should call remoteDataSource.createCompany and return mapped entity when internet is connected',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));

          // Act
          final result = await repository.createCompany(
            tCompanyModel.toEntity(),
          );

          // Assert
          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data, tCompanyModel.toEntity());

          verify(
            () => mockRemoteDataSource.createCompany(
              CompanyRequestModel.fromEntity(tCompanyModel),
            ),
          ).called(1);
        },
      );

      test(
        'should return FailureState when remoteDataSource.createCompany fails',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(() => mockRemoteDataSource.createCompany(any())).thenAnswer(
            (_) async => FailureState<CompanyModel>(message: 'Error'),
          );

          // Act
          final result = await repository.createCompany(
            tCompanyModel.toEntity(),
          );

          // Assert
          expect(result, isA<FailureState<CompanyEntity>>());
          verify(() => mockRemoteDataSource.createCompany(any())).called(1);
        },
      );

      test(
        'should return FailureState when internet is disconnected',
        () async {
          // Arrange
          when(() => mockInternetClient.isConnected).thenReturn(false);

          // Act
          final result = await repository.createCompany(
            tCompanyModel.toEntity(),
          );

          // Assert
          expect(result, isA<FailureState<CompanyEntity>>());
          verifyNever(() => mockRemoteDataSource.createCompany(any()));
        },
      );
    });

    group('getCompany', () {
      test(
        'should call remoteDataSource.getCompany, save it locally, and return mapped entity when internet is connected',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));
          when(
            () => mockLocalDataSource.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getCompany(tCompanyId);

          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data, tCompanyModel.toEntity());
          verify(() => mockRemoteDataSource.getCompany(tCompanyId)).called(1);
          verify(
            () => mockLocalDataSource.saveCompany(tCompanyModel),
          ).called(1);
          verifyNever(() => mockLocalDataSource.getCompany(any()));
        },
      );

      test(
        'should return the error when internet is connected but remoteDataSource fails',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(() => mockRemoteDataSource.getCompany(any())).thenAnswer(
            (_) async => FailureState<CompanyModel>(message: 'Remote Error'),
          );
          when(
            () => mockLocalDataSource.getCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));

          final result = await repository.getCompany(tCompanyId);

          expect(result, isA<FailureState<CompanyEntity>>());
          verify(() => mockRemoteDataSource.getCompany(tCompanyId)).called(1);
          verifyNever(() => mockLocalDataSource.getCompany(any()));
          verifyNever(() => mockLocalDataSource.saveCompany(any()));
        },
      );

      test(
        'should fallback to localDataSource.getCompany when internet is disconnected',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.getCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));

          final result = await repository.getCompany(tCompanyId);

          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data, tCompanyModel.toEntity());
          verifyNever(() => mockRemoteDataSource.getCompany(any()));
          verify(() => mockLocalDataSource.getCompany(tCompanyId)).called(1);
        },
      );

      test('should return FailureState when local fail', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(() => mockLocalDataSource.getCompany(any())).thenAnswer(
          (_) async => FailureState<CompanyModel>(message: 'Local Error'),
        );

        final result = await repository.getCompany(tCompanyId);

        expect(result, isA<FailureState<CompanyEntity>>());
        verifyNever(() => mockRemoteDataSource.getCompany(any()));
        verify(() => mockLocalDataSource.getCompany(tCompanyId)).called(1);
      });

      test(
        'should return cached company on subsequent calls without querying data sources again',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));
          when(
            () => mockLocalDataSource.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result1 = await repository.getCompany(tCompanyId);
          final result2 = await repository.getCompany(tCompanyId);

          expect(result1, isA<SuccessState<CompanyEntity>>());
          expect(result2, isA<SuccessState<CompanyEntity>>());
          expect(result1.data, tCompanyModel.toEntity());
          expect(result2.data, tCompanyModel.toEntity());

          verify(() => mockRemoteDataSource.getCompany(tCompanyId)).called(1);
          verify(
            () => mockLocalDataSource.saveCompany(tCompanyModel),
          ).called(1);
          verifyNever(() => mockLocalDataSource.getCompany(any()));
        },
      );

      test(
        'should bypass cache and query data sources again when forceRefresh is true',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));
          when(
            () => mockLocalDataSource.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result1 = await repository.getCompany(tCompanyId);
          final result2 = await repository.getCompany(tCompanyId, forceRefresh: true);

          expect(result1, isA<SuccessState<CompanyEntity>>());
          expect(result2, isA<SuccessState<CompanyEntity>>());
          expect(result1.data, tCompanyModel.toEntity());
          expect(result2.data, tCompanyModel.toEntity());

          verify(() => mockRemoteDataSource.getCompany(tCompanyId)).called(2);
          verify(
            () => mockLocalDataSource.saveCompany(tCompanyModel),
          ).called(2);
          verifyNever(() => mockLocalDataSource.getCompany(any()));
        },
      );
    });

    group('getCompanyParameters', () {
      test(
        'should call localDataSource.getCompanyParameters and return mapped entity on success',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getCompanyParameters(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyParameterModel));

          // Act
          final result = await repository.getCompanyParameters(tCompanyId);

          // Assert
          expect(result, isA<SuccessState<CompanyParameterEntity>>());
          expect(result.data, tCompanyParameterModel.toEntity());
          verify(
            () => mockLocalDataSource.getCompanyParameters(tCompanyId),
          ).called(1);
        },
      );

      test(
        'should return FailureState when localDataSource.getCompanyParameters fails',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.getCompanyParameters(any()),
          ).thenAnswer(
            (_) async => FailureState<CompanyParameterModel>(message: 'Error'),
          );

          // Act
          final result = await repository.getCompanyParameters(tCompanyId);

          // Assert
          expect(result, isA<FailureState<CompanyParameterEntity>>());
          verify(
            () => mockLocalDataSource.getCompanyParameters(tCompanyId),
          ).called(1);
        },
      );
    });

    group('saveCompany', () {
      test(
        'should call localDataSource.saveCompany and return true on success',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.saveCompany(tCompanyModel.toEntity());

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockLocalDataSource.saveCompany(any())).called(1);
        },
      );
    });

    group('saveCompanyParameters', () {
      test(
        'should call localDataSource.saveCompanyParameters and return true on success',
        () async {
          // Arrange
          when(
            () => mockLocalDataSource.saveCompanyParameters(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          // Act
          final result = await repository.saveCompanyParameters(
            tCompanyParameterModel.toEntity(),
          );

          // Assert
          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockLocalDataSource.saveCompanyParameters(any()),
          ).called(1);
        },
      );
    });
  });
}
