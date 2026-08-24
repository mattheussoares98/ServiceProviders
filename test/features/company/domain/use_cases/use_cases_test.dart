import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/save_company_parameters_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/save_company_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockCompanyRepository mockRepository;
  late CreateCompanyUseCase createCompanyUseCase;
  late GetCompanyUseCase getCompanyUseCase;
  late SaveCompanyUseCase saveCompanyUseCase;
  late GetCompanyParametersUseCase getCompanyParametersUseCase;
  late SaveCompanyParametersUseCase saveCompanyParametersUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCompanyEntity());
    registerFallbackValue(EntityFactory.makeCompanyParameterEntity());
  });

  setUp(() {
    mockRepository = MockCompanyRepository();
    createCompanyUseCase = CreateCompanyUseCase(
      companyRepository: mockRepository,
    );
    getCompanyUseCase = GetCompanyUseCase(companyRepository: mockRepository);
    saveCompanyUseCase = SaveCompanyUseCase(companyRepository: mockRepository);
    getCompanyParametersUseCase = GetCompanyParametersUseCase(
      companyRepository: mockRepository,
    );
    saveCompanyParametersUseCase = SaveCompanyParametersUseCase(
      companyRepository: mockRepository,
    );
  });

  final tCompanyEntity = EntityFactory.makeCompanyEntity();
  final tParametersEntity = EntityFactory.makeCompanyParameterEntity();
  final tCompanyId = tCompanyEntity.id;

  group('Company Use Cases', () {
    group('CreateCompanyUseCase', () {
      test(
        'should call repository.createCompany and return company on success',
        () async {
          when(
            () => mockRepository.createCompany(any()),
          ).thenAnswer((_) async => SuccessState(data: tCompanyEntity));

          final result = await createCompanyUseCase(tCompanyEntity);

          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data, tCompanyEntity);
          verify(() => mockRepository.createCompany(tCompanyEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.createCompany(any())).thenAnswer(
          (_) async => FailureState<CompanyEntity>(message: 'Create failed'),
        );

        final result = await createCompanyUseCase(tCompanyEntity);

        expect(result, isA<FailureState<CompanyEntity>>());
        expect(result.message, 'Create failed');
        verify(() => mockRepository.createCompany(tCompanyEntity)).called(1);
      });
    });

    group('GetCompanyUseCase', () {
      test(
        'should call repository.getCompany and return company on success',
        () async {
          when(
            () => mockRepository.getCompany(
              any(),
              forceRefresh: any(named: 'forceRefresh'),
            ),
          ).thenAnswer((_) async => SuccessState(data: tCompanyEntity));

          final result = await getCompanyUseCase(tCompanyId);

          expect(result, isA<SuccessState<CompanyEntity>>());
          expect(result.data, tCompanyEntity);
          verify(() => mockRepository.getCompany(tCompanyId)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.getCompany(
            any(),
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async => FailureState<CompanyEntity>(message: 'Fetch failed'),
        );

        final result = await getCompanyUseCase(tCompanyId);

        expect(result, isA<FailureState<CompanyEntity>>());
        expect(result.message, 'Fetch failed');
        verify(() => mockRepository.getCompany(tCompanyId)).called(1);
      });
    });

    group('SaveCompanyUseCase', () {
      test(
        'should call repository.saveCompany and return true on success',
        () async {
          when(
            () => mockRepository.saveCompany(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await saveCompanyUseCase(tCompanyEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockRepository.saveCompany(tCompanyEntity)).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(
          () => mockRepository.saveCompany(any()),
        ).thenAnswer((_) async => FailureState<bool>(message: 'Save failed'));

        final result = await saveCompanyUseCase(tCompanyEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Save failed');
        verify(() => mockRepository.saveCompany(tCompanyEntity)).called(1);
      });
    });

    group('GetCompanyParametersUseCase', () {
      test(
        'should call repository.getCompanyParameters and return parameters on success',
        () async {
          when(
            () => mockRepository.getCompanyParameters(any()),
          ).thenAnswer((_) async => SuccessState(data: tParametersEntity));

          final result = await getCompanyParametersUseCase(tCompanyId);

          expect(result, isA<SuccessState<CompanyParameterEntity>>());
          expect(result.data, tParametersEntity);
          verify(
            () => mockRepository.getCompanyParameters(tCompanyId),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.getCompanyParameters(any())).thenAnswer(
          (_) async => FailureState<CompanyParameterEntity>(
            message: 'Fetch parameters failed',
          ),
        );

        final result = await getCompanyParametersUseCase(tCompanyId);

        expect(result, isA<FailureState<CompanyParameterEntity>>());
        expect(result.message, 'Fetch parameters failed');
        verify(() => mockRepository.getCompanyParameters(tCompanyId)).called(1);
      });
    });

    group('SaveCompanyParametersUseCase', () {
      test(
        'should call repository.saveCompanyParameters and return true on success',
        () async {
          when(
            () => mockRepository.saveCompanyParameters(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await saveCompanyParametersUseCase(tParametersEntity);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(
            () => mockRepository.saveCompanyParameters(tParametersEntity),
          ).called(1);
        },
      );

      test('should return FailureState when repository fails', () async {
        when(() => mockRepository.saveCompanyParameters(any())).thenAnswer(
          (_) async => FailureState<bool>(message: 'Save parameters failed'),
        );

        final result = await saveCompanyParametersUseCase(tParametersEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Save parameters failed');
        verify(
          () => mockRepository.saveCompanyParameters(tParametersEntity),
        ).called(1);
      });
    });
  });
}
