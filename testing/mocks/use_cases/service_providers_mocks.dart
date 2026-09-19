import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/delete_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_companies_by_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_invitations_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_auth_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_session_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/send_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/watch_service_provider_companies_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/watch_service_provider_profiles_realtime_use_case.dart';

class MockGetServiceProviderProfilesByAuthUserUseCase extends Mock
    implements GetServiceProviderProfilesByAuthUserUseCase {}

class MockGetServiceProviderCompaniesUseCase extends Mock
    implements GetServiceProviderCompaniesUseCase {}

class MockGetServiceProviderProfilesUseCase extends Mock
    implements GetServiceProviderProfilesUseCase {}

class MockGetServiceProviderInvitationsUseCase extends Mock
    implements GetServiceProviderInvitationsUseCase {}

class MockSendServiceProviderInvitationUseCase extends Mock
    implements SendServiceProviderInvitationUseCase {}

class MockDeleteServiceProviderInvitationUseCase extends Mock
    implements DeleteServiceProviderInvitationUseCase {}

class MockCreateServiceProviderCompanyUseCase extends Mock
    implements CreateServiceProviderCompanyUseCase {}

class MockUpdateServiceProviderCompanyUseCase extends Mock
    implements UpdateServiceProviderCompanyUseCase {}

class MockCreateServiceProviderProfileUseCase extends Mock
    implements CreateServiceProviderProfileUseCase {}

class MockUpdateServiceProviderProfileUseCase extends Mock
    implements UpdateServiceProviderProfileUseCase {}

class MockGetSessionProviderProfileUseCase extends Mock
    implements GetSessionProviderProfileUseCase {}

class MockGetServiceProviderCompaniesByIdsUseCase extends Mock
    implements GetServiceProviderCompaniesByIdsUseCase {}

class MockWatchServiceProviderCompaniesRealtimeUseCase extends Mock
    implements WatchServiceProviderCompaniesRealtimeUseCase {}

class MockWatchServiceProviderProfilesRealtimeUseCase extends Mock
    implements WatchServiceProviderProfilesRealtimeUseCase {}
