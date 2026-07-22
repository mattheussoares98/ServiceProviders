import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/shared_ui/cubits/base/base_cubit.dart';

import '../../../../../../testing/mocks/client_mocks.dart';
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

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

void main() {
  late MockGetServiceProviderCompaniesUseCase mockGetCompanies;
  late MockGetServiceProviderProfilesUseCase mockGetProfiles;
  late MockCreateServiceProviderCompanyUseCase mockCreateCompany;
  late MockCreateServiceProviderProfileUseCase mockCreateProfile;
  late MockUpdateServiceProviderProfileUseCase mockUpdateProfile;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late ServiceProvidersCubit cubit;
  late MockNavigationClient mockNavigationClient;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
  });

  setUp(() {
    mockGetCompanies = MockGetServiceProviderCompaniesUseCase();
    mockGetProfiles = MockGetServiceProviderProfilesUseCase();
    mockCreateCompany = MockCreateServiceProviderCompanyUseCase();
    mockCreateProfile = MockCreateServiceProviderProfileUseCase();
    mockUpdateProfile = MockUpdateServiceProviderProfileUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    cubit = ServiceProvidersCubit(
      getCompanies: mockGetCompanies,
      getProfiles: mockGetProfiles,
      createCompany: mockCreateCompany,
      createProfile: mockCreateProfile,
      updateProfile: mockUpdateProfile,
      getSessionUser: mockGetSessionUser,
    );
  });

  tearDown(GetIt.I.reset);

  group('ServiceProvidersCubit', () {
    test('initial state should be empty', () {
      expect(cubit.state, const ServiceProvidersState.initial());
    });

    group('Load companies', () {
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
    });

    group('Select company', () {});
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
    group('Select profile', () {
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

    group('Save company', () {
      final user = EntityFactory.makeUserProfileEntity();
      final name = faker.company.name();
      final contactEmail = faker.internet.email();
      final contactPhone = faker.randomGenerator.integer(99999999).toString();
      const document = '12345678901';
      const documentType = 'cpf';

      blocTest<ServiceProvidersCubit, ServiceProvidersState>(
        'saveCompany success should create company, call loadCompanies, and return true',
        build: () {
          when(() => mockGetSessionUser.call()).thenReturn(user);
          when(
            () => mockCreateCompany.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetCompanies.call(user.companyId)).thenAnswer(
            (_) async => SuccessState(
              data: [EntityFactory.makeServiceProviderCompanyEntity()],
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.saveCompany(
          name: name,
          contactEmail: contactEmail,
          contactPhone: contactPhone,
          document: document,
          documentType: documentType,
        ),
        expect: () => [
          isA<ServiceProvidersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<ServiceProvidersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<ServiceProvidersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.companies, 'companies', isNotEmpty),
        ],
        verify: (cubit) {
          verify(
            () => mockCreateCompany.call(
              any(
                that: isA<ServiceProviderCompanyEntity>()
                    .having((e) => e.name, 'name', name)
                    .having((e) => e.contactEmail, 'contactEmail', contactEmail)
                    .having((e) => e.contactPhone, 'contactPhone', contactPhone)
                    .having((e) => e.document, 'document', document)
                    .having((e) => e.documentType, 'documentType', documentType)
                    .having((e) => e.companyId, 'companyId', user.companyId),
              ),
            ),
          ).called(1);
        },
      );

      blocTest<ServiceProvidersCubit, ServiceProvidersState>(
        'saveCompany failure should emit savingError state',
        build: () {
          when(() => mockGetSessionUser.call()).thenReturn(user);
          when(() => mockCreateCompany.call(any())).thenAnswer(
            (_) async => FailureState(message: 'Error saving company'),
          );
          return cubit;
        },
        act: (cubit) => cubit.saveCompany(name: name),
        expect: () => [
          isA<ServiceProvidersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<ServiceProvidersState>()
              .having((s) => s.status, 'status', StateStatus.savingError)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Error saving company',
              ),
        ],
        verify: (cubit) {
          verify(
            () => mockCreateCompany.call(
              any(
                that: isA<ServiceProviderCompanyEntity>()
                    .having((e) => e.name, 'name', name)
                    .having((e) => e.companyId, 'companyId', user.companyId),
              ),
            ),
          ).called(1);
        },
      );
    });
  });
}
