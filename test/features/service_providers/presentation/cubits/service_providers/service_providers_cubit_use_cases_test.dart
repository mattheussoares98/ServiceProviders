import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/presentation/cubits/service_providers/service_providers_cubit_use_cases.dart';

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

  setUp(() {
    mockGetCompanies = MockGetServiceProviderCompaniesUseCase();
    mockGetProfiles = MockGetServiceProviderProfilesUseCase();
    mockCreateCompany = MockCreateServiceProviderCompanyUseCase();
    mockUpdateCompany = MockUpdateServiceProviderCompanyUseCase();
    mockCreateProfile = MockCreateServiceProviderProfileUseCase();
    mockUpdateProfile = MockUpdateServiceProviderProfileUseCase();
    mockGetSessionUser = MockGetSessionUserUseCase();

    useCases = ServiceProvidersCubitUseCases(
      getCompanies: mockGetCompanies,
      getProfiles: mockGetProfiles,
      createCompany: mockCreateCompany,
      updateCompany: mockUpdateCompany,
      createProfile: mockCreateProfile,
      updateProfile: mockUpdateProfile,
      getSessionUser: mockGetSessionUser,
    );
  });

  test('ServiceProvidersCubitUseCases retains injected use cases', () {
    expect(useCases.getCompanies, equals(mockGetCompanies));
    expect(useCases.getProfiles, equals(mockGetProfiles));
    expect(useCases.createCompany, equals(mockCreateCompany));
    expect(useCases.updateCompany, equals(mockUpdateCompany));
    expect(useCases.createProfile, equals(mockCreateProfile));
    expect(useCases.updateProfile, equals(mockUpdateProfile));
    expect(useCases.getSessionUser, equals(mockGetSessionUser));
  });
}
