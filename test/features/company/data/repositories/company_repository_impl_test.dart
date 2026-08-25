import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_parameter_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';
import 'package:o_jogo_da_obra/features/company/data/repositories/company_repository_impl.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockCompanyRemoteDataSource mockRemoteDataSource;
  late MockCompanyLocalDataSource mockLocalDataSource;
  late CompanyRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      CompanyModel.fromEntity(EntityFactory.makeCompanyEntity()),
    );
    registerFallbackValue(
      CompanyParameterModel.fromEntity(
        EntityFactory.makeCompanyParameterEntity(),
      ),
    );
    registerFallbackValue(
      CompanyRequestModel.fromEntity(EntityFactory.makeCompanyEntity()),
    );
    registerFallbackValue(
      CompanyParameterRequestModel.fromEntity(
        EntityFactory.makeCompanyParameterEntity(),
      ),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockCompanyRemoteDataSource();
    mockLocalDataSource = MockCompanyLocalDataSource();
    repository = CompanyRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tCompanyEntity = EntityFactory.makeCompanyEntity();
  final tCompanyId = tCompanyEntity.id;
  final tCompanyModel = CompanyModel.fromEntity(tCompanyEntity);

  final tCompanyParameterEntity = EntityFactory.makeCompanyParameterEntity()
      .copyWith(companyId: tCompanyId);
  final tCompanyParameterModel = CompanyParameterModel.fromEntity(
    tCompanyParameterEntity,
  );

  group('CompanyRepositoryImpl', () {
    group('createCompany', () {
      test(
        'should call remoteDataSource.createCompany and return mapped entity when internet is connected',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.createCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));

          final result = await repository.createCompany(
            tCompanyModel.toEntity(),
          );

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
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(() => mockRemoteDataSource.createCompany(any())).thenAnswer(
            (_) async => FailureState<CompanyModel>(message: 'Error'),
          );

          final result = await repository.createCompany(
            tCompanyModel.toEntity(),
          );

          expect(result, isA<FailureState<CompanyEntity>>());
          verify(() => mockRemoteDataSource.createCompany(any())).called(1);
        },
      );

      test(
        'should return FailureState when internet is disconnected',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);

          final result = await repository.createCompany(
            tCompanyModel.toEntity(),
          );

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

      test('should return FailureState when local fails', () async {
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
          final result2 = await repository.getCompany(
            tCompanyId,
            forceRefresh: true,
          );

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
        'should call remoteDataSource when online, save locally, and return mapped entity',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.getCompanyParameters(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyParameterModel));
          when(
            () => mockLocalDataSource.saveCompanyParameters(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.getCompanyParameters(tCompanyId);

          expect(result, isA<SuccessState<CompanyParameterEntity>>());
          expect(result.data, tCompanyParameterModel.toEntity());
          verify(
            () => mockRemoteDataSource.getCompanyParameters(tCompanyId),
          ).called(1);
          verify(
            () => mockLocalDataSource.saveCompanyParameters(
              tCompanyParameterModel,
            ),
          ).called(1);
          verifyNever(() => mockLocalDataSource.getCompanyParameters(any()));
        },
      );

      test('should fallback to localDataSource when offline', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.getCompanyParameters(any()),
        ).thenAnswer((_) async => SuccessState(data: tCompanyParameterModel));

        final result = await repository.getCompanyParameters(tCompanyId);

        expect(result, isA<SuccessState<CompanyParameterEntity>>());
        expect(result.data, tCompanyParameterModel.toEntity());
        verifyNever(() => mockRemoteDataSource.getCompanyParameters(any()));
        verify(
          () => mockLocalDataSource.getCompanyParameters(tCompanyId),
        ).called(1);
      });

      test('should return FailureState when offline and local fails', () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(() => mockLocalDataSource.getCompanyParameters(any())).thenAnswer(
          (_) async => FailureState<CompanyParameterModel>(message: 'Error'),
        );

        final result = await repository.getCompanyParameters(tCompanyId);

        expect(result, isA<FailureState<CompanyParameterEntity>>());
        verify(
          () => mockLocalDataSource.getCompanyParameters(tCompanyId),
        ).called(1);
      });
    });

    group('saveCompany', () {
      test(
        'should call remote and local when online and return true on success',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyModel));
          when(
            () => mockLocalDataSource.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.saveCompany(tCompanyModel.toEntity());

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRemoteDataSource.updateCompany(
              CompanyRequestModel.fromEntity(tCompanyModel),
            ),
          ).called(1);
          verify(
            () => mockLocalDataSource.saveCompany(tCompanyModel),
          ).called(1);
        },
      );

      test(
        'should return FailureState when online and remote update fails',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.updateCompany(any()),
          ).thenAnswer(
            (_) async => FailureState<CompanyModel>(message: 'Error'),
          );

          final result = await repository.saveCompany(tCompanyModel.toEntity());

          expect(result, isA<FailureState<bool>>());
          verify(
            () => mockRemoteDataSource.updateCompany(
              CompanyRequestModel.fromEntity(tCompanyModel),
            ),
          ).called(1);
          verifyNever(() => mockLocalDataSource.saveCompany(any()));
        },
      );

      test(
        'should call only localDataSource when offline and return true on success',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.saveCompany(tCompanyModel.toEntity());

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verifyNever(() => mockRemoteDataSource.updateCompany(any()));
          verify(
            () => mockLocalDataSource.saveCompany(tCompanyModel),
          ).called(1);
        },
      );
    });

    group('saveCompanyParameters', () {
      test(
        'should call remote and local when online and return true on success',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.saveCompanyParameters(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyParameterModel));
          when(
            () => mockLocalDataSource.saveCompanyParameters(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.saveCompanyParameters(
            tCompanyParameterModel.toEntity(),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRemoteDataSource.saveCompanyParameters(any()),
          ).called(1);
          verify(
            () => mockLocalDataSource.saveCompanyParameters(any()),
          ).called(1);
        },
      );

      test('should return failure when online and remote save fails', () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.saveCompanyParameters(any()),
        ).thenAnswer(
          (_) async =>
              FailureState<CompanyParameterModel>(message: 'Remote Error'),
        );

        final result = await repository.saveCompanyParameters(
          tCompanyParameterModel.toEntity(),
        );

        expect(result, isA<FailureState<bool>>());
        verify(
          () => mockRemoteDataSource.saveCompanyParameters(any()),
        ).called(1);
        verifyNever(() => mockLocalDataSource.saveCompanyParameters(any()));
      });

      test(
        'should save locally when offline and return true on success',
        () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);
          when(
            () => mockLocalDataSource.saveCompanyParameters(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await repository.saveCompanyParameters(
            tCompanyParameterModel.toEntity(),
          );

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verifyNever(() => mockRemoteDataSource.saveCompanyParameters(any()));
          verify(
            () => mockLocalDataSource.saveCompanyParameters(any()),
          ).called(1);
        },
      );
    });
  });
}
