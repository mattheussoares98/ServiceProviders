import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/create_service_provider_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/delete_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_invitations_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/get_service_provider_profiles_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/send_service_provider_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_company_use_case.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/use_cases/update_service_provider_profile_use_case.dart';

@LazySingleton()
class ServiceProvidersCubitUseCases {
  ServiceProvidersCubitUseCases({
    required this.getCompanies,
    required this.getProfiles,
    required this.getInvitations,
    required this.sendInvitation,
    required this.deleteInvitation,
    required this.createCompany,
    required this.updateCompany,
    required this.createProfile,
    required this.updateProfile,
    required this.getSessionUser,
  });

  final GetServiceProviderCompaniesUseCase getCompanies;
  final GetServiceProviderProfilesUseCase getProfiles;
  final GetServiceProviderInvitationsUseCase getInvitations;
  final SendServiceProviderInvitationUseCase sendInvitation;
  final DeleteServiceProviderInvitationUseCase deleteInvitation;
  final CreateServiceProviderCompanyUseCase createCompany;
  final UpdateServiceProviderCompanyUseCase updateCompany;
  final CreateServiceProviderProfileUseCase createProfile;
  final UpdateServiceProviderProfileUseCase updateProfile;
  final GetSessionUserUseCase getSessionUser;
}
