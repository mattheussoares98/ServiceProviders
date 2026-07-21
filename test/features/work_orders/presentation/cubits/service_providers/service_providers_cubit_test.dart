import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

class MockGetServiceProviderCompaniesUseCase extends Mock
    implements GetServiceProviderCompaniesUseCase {}

class MockGetServiceProviderProfilesUseCase extends Mock
    implements GetServiceProviderProfilesUseCase {}

class MockCreateServiceProviderCompanyUseCase extends Mock
    implements CreateServiceProviderCompanyUseCase {}

class MockUpdateServiceProviderCompanyUseCase extends Mock
    implements UpdateServiceProviderCompanyUseCase {}

class MockCreateServiceProviderProfileUseCase extends Mock
    implements CreateServiceProviderProfileUseCase {}

class MockUpdateServiceProviderProfileUseCase extends Mock
    implements UpdateServiceProviderProfileUseCase {}

void main() {
  late MockGetServiceProviderCompaniesUseCase mockGetCompanies;
  late MockGetServiceProviderProfilesUseCase mockGetProfiles;
  late MockCreateServiceProviderCompanyUseCase mockCreateCompany;
  late MockUpdateServiceProviderCompanyUseCase mockUpdateCompany;
  late MockCreateServiceProviderProfileUseCase mockCreateProfile;
  late MockUpdateServiceProviderProfileUseCase mockUpdateProfile;
  late ServiceProvidersCubit cubit;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
  });

  setUp(() {
    mockGetCompanies = MockGetServiceProviderCompaniesUseCase();
    mockGetProfiles = MockGetServiceProviderProfilesUseCase();
    mockCreateCompany = MockCreateServiceProviderCompanyUseCase();
    mockUpdateCompany = MockUpdateServiceProviderCompanyUseCase();
    mockCreateProfile = MockCreateServiceProviderProfileUseCase();
    mockUpdateProfile = MockUpdateServiceProviderProfileUseCase();

    cubit = ServiceProvidersCubit(
      getCompanies: mockGetCompanies,
      getProfiles: mockGetProfiles,
      createCompany: mockCreateCompany,
      updateCompany: mockUpdateCompany,
      createProfile: mockCreateProfile,
      updateProfile: mockUpdateProfile,
    );
  });

  group('ServiceProvidersCubit', () {
    test('initial state should be empty', () {
      expect(cubit.state, const ServiceProvidersState.initial());
    });

    blocTest<ServiceProvidersCubit, ServiceProvidersState>(
      'loadCompanies should fetch companies and emit loaded',
      build: () {
        when(() => mockGetCompanies.call(any())).thenAnswer(
          (_) async => SuccessState(
            data: [EntityFactory.makeServiceProviderCompanyEntity()],
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.loadCompanies(faker.guid.guid()),
      expect: () => [
        isA<ServiceProvidersState>().having(
          (s) => s.status,
          'status',
          StateStatus.loading,
        ),
        isA<ServiceProvidersState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.companies, 'companies', isNotEmpty),
      ],
    );

    blocTest<ServiceProvidersCubit, ServiceProvidersState>(
      'selectCompany should load profiles and emit loaded',
      build: () {
        when(() => mockGetProfiles.call(any())).thenAnswer(
          (_) async => SuccessState(
            data: [EntityFactory.makeServiceProviderProfileEntity()],
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.selectCompany(faker.guid.guid()),
      expect: () => [
        isA<ServiceProvidersState>()
            .having((s) => s.status, 'status', StateStatus.loading)
            .having((s) => s.selectedCompanyId, 'selectedCompanyId', isNotNull),
        isA<ServiceProvidersState>()
            .having((s) => s.status, 'status', StateStatus.loaded)
            .having((s) => s.profiles, 'profiles', isNotEmpty),
      ],
    );

    blocTest<ServiceProvidersCubit, ServiceProvidersState>(
      'selectProfile should update selectedProfileId',
      build: () => cubit,
      act: (cubit) => cubit.selectProfile('some-profile-id'),
      expect: () => [
        isA<ServiceProvidersState>().having(
          (s) => s.selectedProfileId,
          'selectedProfileId',
          'some-profile-id',
        ),
      ],
    );
  });
}
