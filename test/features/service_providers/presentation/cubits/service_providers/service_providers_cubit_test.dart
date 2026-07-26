import 'package:bloc_test/bloc_test.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/document_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit_use_cases.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';
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
  late MockUpdateServiceProviderCompanyUseCase mockUpdateCompany;
  late MockCreateServiceProviderProfileUseCase mockCreateProfile;
  late MockUpdateServiceProviderProfileUseCase mockUpdateProfile;
  late MockGetSessionUserUseCase mockGetSessionUser;
  late ServiceProvidersCubitUseCases useCases;
  late ServiceProvidersCubit cubit;
  late MockNavigationClient mockNavigationClient;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
    registerFallbackValue(
      CreateUpdateServiceProviderCompanyRoute(serviceProviderCompanyId: '1'),
    );
  });

  setUp(() {
    mockGetCompanies = MockGetServiceProviderCompaniesUseCase();
    mockGetProfiles = MockGetServiceProviderProfilesUseCase();
    mockCreateCompany = MockCreateServiceProviderCompanyUseCase();
    mockUpdateCompany = MockUpdateServiceProviderCompanyUseCase();
    mockCreateProfile = MockCreateServiceProviderProfileUseCase();
    mockUpdateProfile = MockUpdateServiceProviderProfileUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();
    mockNavigationClient = MockNavigationClient();

    GetIt.I.registerSingleton<NavigationClient>(mockNavigationClient);

    useCases = ServiceProvidersCubitUseCases(
      getCompanies: mockGetCompanies,
      getProfiles: mockGetProfiles,
      createCompany: mockCreateCompany,
      updateCompany: mockUpdateCompany,
      createProfile: mockCreateProfile,
      updateProfile: mockUpdateProfile,
      getSessionUser: mockGetSessionUser,
    );

    cubit = ServiceProvidersCubit(useCases: useCases);
  });

  tearDown(GetIt.I.reset);

  group('ServiceProvidersCubit', () {
    test('initial state should be empty', () {
      expect(cubit.state, const ServiceProvidersState.initial());
    });

    group('loadCompanies', () {
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
        'loadCompanies with emitLoading: false should not emit loading status',
        build: () {
          when(() => mockGetCompanies.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: [EntityFactory.makeServiceProviderCompanyEntity()],
            ),
          );
          return cubit;
        },
        act: (cubit) =>
            cubit.loadCompanies(faker.guid.guid(), emitLoading: false),
        expect: () => [
          isA<ServiceProvidersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.companies.length, 'companies.length', 1),
        ],
      );

      blocTest<ServiceProvidersCubit, ServiceProvidersState>(
        'loadCompanies should emit loadingError on failure',
        build: () {
          when(
            () => mockGetCompanies.call(any()),
          ).thenAnswer((_) async => FailureState(message: 'Error loading'));
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
              .having((s) => s.status, 'status', StateStatus.loadingError)
              .having((s) => s.errorMessage, 'errorMessage', 'Error loading'),
        ],
      );
    });

    group('selectCompany', () {
      blocTest<ServiceProvidersCubit, ServiceProvidersState>(
        'selectCompany(null) should clear selectedCompanyId and selectedProfileId',
        build: () => cubit,
        act: (cubit) => cubit.selectCompany(null),
        expect: () => [
          isA<ServiceProvidersState>()
              .having((s) => s.selectedCompanyId, 'selectedCompanyId', null)
              .having((s) => s.selectedProfileId, 'selectedProfileId', null),
        ],
      );

      blocTest<ServiceProvidersCubit, ServiceProvidersState>(
        'selectCompany(id) should fetch profiles and update profiles map',
        build: () {
          when(() => mockGetProfiles.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: [EntityFactory.makeServiceProviderProfileEntity()],
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.selectCompany('comp-1'),
        expect: () => [
          isA<ServiceProvidersState>().having(
            (s) => s.selectedCompanyId,
            'selectedCompanyId',
            'comp-1',
          ),
          isA<ServiceProvidersState>().having(
            (s) => s.status,
            'status',
            StateStatus.loading,
          ),
          isA<ServiceProvidersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.profiles['comp-1']?.length, 'profiles count', 1),
        ],
      );
    });

    group('selectProfile', () {
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

    group('saveCompany', () {
      final user = EntityFactory.makeUserProfileEntity();
      final name = faker.company.name();
      final contactEmail = faker.internet.email();
      final contactPhone = faker.randomGenerator.integer(99999999).toString();
      const document = '12345678901';
      const documentType = DocumentType.cpf;

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
        act: (cubit) => cubit.saveCompany(
          name: name,
          document: '323234',
          documentType: DocumentType.cnpj,
        ),
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

    group('saveProfile', () {
      blocTest<ServiceProvidersCubit, ServiceProvidersState>(
        'saveProfile should call createProfile when profileId is null and transition saving -> loaded without loading state',
        build: () {
          when(
            () => mockCreateProfile.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockGetProfiles.call(any())).thenAnswer(
            (_) async => SuccessState(
              data: [EntityFactory.makeServiceProviderProfileEntity()],
            ),
          );
          return cubit;
        },
        act: (cubit) => cubit.saveProfile(
          serviceProviderCompanyId: 'comp-1',
          name: faker.person.name(),
          email: faker.internet.email(),
          phone: '11999999999',
        ),
        expect: () => [
          isA<ServiceProvidersState>().having(
            (s) => s.status,
            'status',
            StateStatus.saving,
          ),
          isA<ServiceProvidersState>()
              .having((s) => s.status, 'status', StateStatus.loaded)
              .having((s) => s.profiles['comp-1']?.length, 'profiles count', 1),
        ],
        verify: (_) {
          verify(() => mockCreateProfile.call(any())).called(1);
          verify(() => mockGetProfiles.call('comp-1')).called(1);
        },
      );
    });

    group('Navigation', () {
      test(
        'navigateToCreateUpdateServiceProviderCompany should push CreateUpdateServiceProviderCompanyRoute with cubit',
        () async {
          when(
            () => mockNavigationClient
                .pushRoute<CreateUpdateServiceProviderCompanyRouteArgs>(any()),
          ).thenAnswer((_) async => null);

          await cubit.navigateToCreateUpdateServiceProviderCompany('comp-1');

          verify(
            () => mockNavigationClient
                .pushRoute<CreateUpdateServiceProviderCompanyRouteArgs>(
                  any(
                    that: isA<CreateUpdateServiceProviderCompanyRoute>().having(
                      (r) => r.args!.serviceProviderCompanyId,
                      'serviceProviderCompanyId',
                      'comp-1',
                    ),
                  ),
                ),
          ).called(1);
        },
      );
    });
  });
}
