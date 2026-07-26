import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockServiceProviderRepository mockServiceProviderRepository;

  late CreateServiceProviderCompanyUseCase createServiceProviderCompanyUseCase;
  late UpdateServiceProviderCompanyUseCase updateServiceProviderCompanyUseCase;
  late CreateServiceProviderProfileUseCase createServiceProviderProfileUseCase;
  late UpdateServiceProviderProfileUseCase updateServiceProviderProfileUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
  });

  setUp(() {
    mockServiceProviderRepository = MockServiceProviderRepository();

    createServiceProviderCompanyUseCase = CreateServiceProviderCompanyUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    updateServiceProviderCompanyUseCase = UpdateServiceProviderCompanyUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    createServiceProviderProfileUseCase = CreateServiceProviderProfileUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
    updateServiceProviderProfileUseCase = UpdateServiceProviderProfileUseCase(
      serviceProviderRepository: mockServiceProviderRepository,
    );
  });

  group('CreateServiceProviderCompanyUseCase', () {
    final tCompany = EntityFactory.makeServiceProviderCompanyEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.createServiceProviderCompany(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createServiceProviderCompanyUseCase(tCompany);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.createServiceProviderCompany(
          tCompany,
        ),
      ).called(1);
    });
  });

  group('UpdateServiceProviderCompanyUseCase', () {
    final tCompany = EntityFactory.makeServiceProviderCompanyEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.updateServiceProviderCompany(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await updateServiceProviderCompanyUseCase(tCompany);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.updateServiceProviderCompany(
          tCompany,
        ),
      ).called(1);
    });
  });

  group('CreateServiceProviderProfileUseCase', () {
    final tProfile = EntityFactory.makeServiceProviderProfileEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.createServiceProviderProfile(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await createServiceProviderProfileUseCase(tProfile);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.createServiceProviderProfile(
          tProfile,
        ),
      ).called(1);
    });
  });

  group('UpdateServiceProviderProfileUseCase', () {
    final tProfile = EntityFactory.makeServiceProviderProfileEntity();

    test('should return true on success', () async {
      when(
        () => mockServiceProviderRepository.updateServiceProviderProfile(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await updateServiceProviderProfileUseCase(tProfile);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockServiceProviderRepository.updateServiceProviderProfile(
          tProfile,
        ),
      ).called(1);
    });
  });
}
