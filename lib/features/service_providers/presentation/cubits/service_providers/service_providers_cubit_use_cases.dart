import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/delete_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_invitations_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_by_company_ids_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/send_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';

@LazySingleton()
class ServiceProvidersCubitUseCases {
  ServiceProvidersCubitUseCases({
    required this.getCompanies,
    required this.getProfiles,
    required this.getProfilesByCompanyIds,
    required this.getInvitations,
    required this.sendInvitation,
    required this.deleteInvitation,
    required this.createCompany,
    required this.updateCompany,
    required this.createProfile,
    required this.updateProfile,
    required this.getActiveCompanyId,
  });

  final GetServiceProviderCompaniesUseCase getCompanies;
  final GetServiceProviderProfilesUseCase getProfiles;
  final GetServiceProviderProfilesByCompanyIdsUseCase getProfilesByCompanyIds;
  final GetServiceProviderInvitationsUseCase getInvitations;
  final SendServiceProviderInvitationUseCase sendInvitation;
  final DeleteServiceProviderInvitationUseCase deleteInvitation;
  final CreateServiceProviderCompanyUseCase createCompany;
  final UpdateServiceProviderCompanyUseCase updateCompany;
  final CreateServiceProviderProfileUseCase createProfile;
  final UpdateServiceProviderProfileUseCase updateProfile;
  final GetActiveCompanyIdUseCase getActiveCompanyId;
}
