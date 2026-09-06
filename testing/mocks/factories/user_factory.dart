import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/auth_user_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/authentication_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/sign_up_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/verify_otp_request_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/configurations/domain/entities/configurations_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission/permission.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'factory_helpers.dart';

abstract final class UserFactory {
  static CompanyEntity makeCompanyEntity() {
    return CompanyEntity(
      id: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      cnpj: '12345678000199',
      logoUrl: FactoryHelpers.makeHttps(),
      isActive: true,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
    );
  }

  static List<CompanyEntity> makeCompanyEntityList() {
    return [makeCompanyEntity(), makeCompanyEntity(), makeCompanyEntity()];
  }

  static CompanyParameterEntity makeCompanyParameterEntity() {
    return CompanyParameterEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      maxOfflineDurationHours: 2,
      maxOfflinePendingRequests: 10,
      offlineAlertThrottleFrequency: 3,
      maxImageSizeMb: 20,
      maxVideoSizeMb: 500,
      maxPdfSizeMb: 10,
      maxDocumentSizeMb: 5,
      sandboxQuotaMb: 1024,
      maxSyncAttempts: 3,
      inviteExpiryHours: 24,
      advanceWarningGroupIds: [FactoryHelpers.makeId(), FactoryHelpers.makeId(), FactoryHelpers.makeId()],
      escalationGroupIds: [FactoryHelpers.makeId(), FactoryHelpers.makeId(), FactoryHelpers.makeId()],
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
    );
  }

  static List<CompanyParameterEntity> makeCompanyParameterEntityList() {
    return [
      makeCompanyParameterEntity(),
      makeCompanyParameterEntity(),
      makeCompanyParameterEntity(),
    ];
  }

  // UserProfile
  static UserProfileEntity makeUserProfileEntity() {
    return UserProfileEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makePersonName(),
      email: FactoryHelpers.makeEmail(),
      phone: FactoryHelpers.makeInt(99999999, min: 10000000).toString(),
      isActive: true,
      isAdmin: false,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      avatarUrl: FactoryHelpers.makeUrl(),
      deletedAt: null,
      lastAccessAt: FactoryHelpers.makeDateTime(),
      permissionGroupId: FactoryHelpers.makeId(),
    );
  }

  static List<UserProfileEntity> makeUserProfileEntityList() {
    return [
      makeUserProfileEntity(),
      makeUserProfileEntity(),
      makeUserProfileEntity(),
    ];
  }

  // PermissionGroup
  static PermissionGroupEntity makePermissionGroupEntity() {
    return PermissionGroupEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeWord(),
      deletedAt: null,
      permissions: const {
        ResourceType.attachments: {
          PermissionAction.create,
          PermissionAction.read,
          PermissionAction.update,
          PermissionAction.delete,
        },
      },
      workOrders: const WorkOrdersPermissionEntity.defaultTechnical(),
      isDefault: false,
      createdAt: FactoryHelpers.makeDateTime(),
      rawPermissions: const {
        'attachments.create': true,
        'attachments.read': true,
        'attachments.update': true,
        'attachments.delete': true,
        'work_orders.read_scope': 'assigned',
        'work_orders.create': false,
        'work_orders.update_scope': 'assigned',
        'work_orders.delete': false,
        'work_orders.change_status': true,
        'work_orders.reassign': false,
        'work_orders.manage_pending_requests': false,
        'work_orders.delete_observation': false,
      },
    );
  }

  static List<PermissionGroupEntity> makePermissionGroupEntityList() {
    return [
      makePermissionGroupEntity(),
      makePermissionGroupEntity(),
      makePermissionGroupEntity(),
    ];
  }

  // MaintenancePlan
  static User makeUser() {
    return User(
      id: FactoryHelpers.makeId(),
      appMetadata: const {},
      userMetadata: const {},
      aud: FactoryHelpers.makeString(5),
      createdAt: FactoryHelpers.makeDateTime().toIso8601String(),
    );
  }

  static UserDataEntity makeUserDataEntity() {
    return UserDataEntity(
      user: makeUserProfileEntity(),
      accessToken: faker.jwt.valid(),
      refreshToken: faker.jwt.valid(),
    );
  }

  static AuthUserEntity makeAuthUserEntity() {
    return AuthUserEntity(
      id: FactoryHelpers.makeId(),
      email: FactoryHelpers.makeEmail(),
      name: FactoryHelpers.makePersonName(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
    );
  }

  static AuthenticationEntity makeAuthentication() {
    return AuthenticationEntity(email: FactoryHelpers.makeEmail(), password: FactoryHelpers.makePassword());
  }

  static SignUpEntity makeSignUp() {
    return SignUpEntity(
      name: FactoryHelpers.makePersonName(),
      email: FactoryHelpers.makeEmail(),
      password: FactoryHelpers.makePassword(),
    );
  }

  static VerifyOtpRequestEntity makeVerifyOtpRequestEntity() {
    return VerifyOtpRequestEntity(tokenHash: FactoryHelpers.makeId());
  }

  static List<VerifyOtpRequestEntity> makeVerifyOtpRequestEntityList() {
    return [
      makeVerifyOtpRequestEntity(),
      makeVerifyOtpRequestEntity(),
      makeVerifyOtpRequestEntity(),
    ];
  }

  static AuthenticationRequestModel makeAuthenticationModel() {
    return AuthenticationRequestModel(
      email: FactoryHelpers.makeEmail(),
      password: FactoryHelpers.makePassword(),
    );
  }

  static SignUpRequestModel makeSignUpRequest() {
    return SignUpRequestModel(
      name: FactoryHelpers.makePersonName(),
      email: FactoryHelpers.makeEmail(),
      password: FactoryHelpers.makePassword(),
    );
  }

  static ConfigurationsEntity makeConfigurationsEntity() {
    return ConfigurationsEntity(
      pushNotificationsEnabled: FactoryHelpers.makeBool(),
      themeMode: faker.randomGenerator.element(['light', 'dark', 'system']),
      systemNotificationsEnabled: FactoryHelpers.makeBool(),
    );
  }

  // UserInvitation
  static UserInvitationEntity makeUserInvitationEntity() {
    return UserInvitationEntity(
      id: FactoryHelpers.makeId(),
      email: FactoryHelpers.makeEmail(),
      invitedAt: FactoryHelpers.makeDateTime(),
      companyId: FactoryHelpers.makeId(),
      permissionGroupId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makePersonName(),
      confirmationSentAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<UserInvitationEntity> makeUserInvitationEntityList() {
    return [
      makeUserInvitationEntity(),
      makeUserInvitationEntity(),
      makeUserInvitationEntity(),
    ];
  }

}
