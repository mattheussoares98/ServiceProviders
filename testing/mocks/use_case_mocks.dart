import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/get_session_user_use_case.dart';
import 'package:o_jogo_da_obra/features/assets/domain/use_cases/watch_assets_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/use_cases/pick_attachment_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/change_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_active_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_selected_mode_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/get_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/log_out_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/login_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/save_user_data_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_selected_company_id_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/set_session_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:o_jogo_da_obra/features/auth/domain/use_cases/watch_session_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/create_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_all_companies_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/get_company_use_case.dart';
import 'package:o_jogo_da_obra/features/company/domain/use_cases/update_company_logo_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/watch_areas_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/locations/domain/use_cases/watch_locations_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/delete_device_token_use_case.dart';
import 'package:o_jogo_da_obra/features/notifications/domain/use_cases/register_device_token_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/create_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/delete_sector_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/get_sectors_use_case.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/use_cases/update_sector_use_case.dart';
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
import 'package:o_jogo_da_obra/features/users/domain/use_cases/create_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_orders_realtime_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_pending_invitations_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/has_permission_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/resend_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/revoke_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/get_provider_work_orders_use_case.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/use_cases/watch_work_orders_realtime_use_case.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockLogOutUseCase extends Mock implements LogOutUseCase {}

class MockSetSessionUseCase extends Mock implements SetSessionUseCase {}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

class MockGetUserDataUseCase extends Mock implements GetUserDataUseCase {}

class MockSaveUserDataUseCase extends Mock implements SaveUserDataUseCase {}

class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}

class MockCreateCompanyUseCase extends Mock implements CreateCompanyUseCase {}

class MockGetSessionUserUseCase extends Mock implements GetSessionUserUseCase {}

class MockGetActiveCompanyIdUseCase extends Mock
    implements GetActiveCompanyIdUseCase {}

class MockWatchSessionUseCase extends Mock implements WatchSessionUseCase {}

class MockGetCompanyUseCase extends Mock implements GetCompanyUseCase {}

class MockGetServiceProviderProfilesByAuthUserUseCase extends Mock
    implements GetServiceProviderProfilesByAuthUserUseCase {}

class MockGetSectorsUseCase extends Mock implements GetSectorsUseCase {}

class MockCreateSectorUseCase extends Mock implements CreateSectorUseCase {}

class MockUpdateSectorUseCase extends Mock implements UpdateSectorUseCase {}

class MockDeleteSectorUseCase extends Mock implements DeleteSectorUseCase {}

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

class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}

class MockGetUserProfileByIdUseCase extends Mock
    implements GetUserProfileByIdUseCase {}

class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

class MockDeleteUserProfileUseCase extends Mock
    implements DeleteUserProfileUseCase {}

class MockGetPermissionGroupsUseCase extends Mock
    implements GetPermissionGroupsUseCase {}

class MockCreatePermissionGroupUseCase extends Mock
    implements CreatePermissionGroupUseCase {}

class MockUpdatePermissionGroupUseCase extends Mock
    implements UpdatePermissionGroupUseCase {}

class MockDeletePermissionGroupUseCase extends Mock
    implements DeletePermissionGroupUseCase {}

class MockGetPendingInvitationsUseCase extends Mock
    implements GetPendingInvitationsUseCase {}

class MockRevokeInvitationUseCase extends Mock
    implements RevokeInvitationUseCase {}

class MockResendInvitationUseCase extends Mock
    implements ResendInvitationUseCase {}

class MockHasPermissionUseCase extends Mock implements HasPermissionUseCase {}

class MockGetProviderWorkOrdersUseCase extends Mock
    implements GetProviderWorkOrdersUseCase {}

class MockGetSessionProviderProfileUseCase extends Mock
    implements GetSessionProviderProfileUseCase {}

class MockGetServiceProviderCompaniesByIdsUseCase extends Mock
    implements GetServiceProviderCompaniesByIdsUseCase {}

class MockGetSelectedModeUseCase extends Mock
    implements GetSelectedModeUseCase {}

class MockRegisterDeviceTokenUseCase extends Mock
    implements RegisterDeviceTokenUseCase {}

class MockDeleteDeviceTokenUseCase extends Mock
    implements DeleteDeviceTokenUseCase {}

class MockPickAttachmentUseCase extends Mock implements PickAttachmentUseCase {}

class MockUpdateCompanyLogoUseCase extends Mock
    implements UpdateCompanyLogoUseCase {}

class MockGetAllCompaniesUseCase extends Mock
    implements GetAllCompaniesUseCase {}

class MockSetSelectedCompanyIdUseCase extends Mock
    implements SetSelectedCompanyIdUseCase {}

class MockWatchWorkOrdersRealtimeUseCase extends Mock
    implements WatchWorkOrdersRealtimeUseCase {}

class MockWatchLocationsRealtimeUseCase extends Mock
    implements WatchLocationsRealtimeUseCase {}

class MockWatchAreasRealtimeUseCase extends Mock
    implements WatchAreasRealtimeUseCase {}

class MockWatchAssetsRealtimeUseCase extends Mock
    implements WatchAssetsRealtimeUseCase {}
