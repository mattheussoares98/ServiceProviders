import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockCompanyRepository mockRepository;
  late CreateCompanyUseCase createCompanyUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeCompanyEntity());
  });

  setUp(() {
    mockRepository = MockCompanyRepository();
    createCompanyUseCase = CreateCompanyUseCase(
      companyRepository: mockRepository,
    );
  });

  final tCompanyEntity = EntityFactory.makeCompanyEntity();

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
  });
}
