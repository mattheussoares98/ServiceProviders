import 'package:clean_architecture/core/domain/entities/user_data_entity.dart';
import 'package:clean_architecture/core/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/attachments/domain/entities/attachment_entity.dart';
import 'package:clean_architecture/features/attachments/domain/entities/file_type.dart';
import 'package:clean_architecture/features/attachments/domain/entities/upload_status.dart';
import 'package:clean_architecture/features/auth/data/models/requests/authentication_request_model.dart';
import 'package:clean_architecture/features/auth/data/models/requests/sign_up_request_model.dart';
import 'package:clean_architecture/features/auth/domain/entities/authentication_entity.dart';
import 'package:clean_architecture/features/auth/domain/entities/sign_up_entity.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/checklists/domain/entities/checklist_template_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:clean_architecture/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:faker/faker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single helper factory for generating entities and request models in test suites.
abstract final class TestFactory {
  static AssetEntity makeAssetEntity() {
    return AssetEntity(
      id: faker.guid.guid(),
      companyId: faker.guid.guid(),
      areaId: faker.guid.guid(),
      categoryId: faker.guid.guid(),
      name: faker.company.name(),
      code: faker.randomGenerator.string(8),
      manufacturer: faker.company.name(),
      model: faker.vehicle.model(),
      serialNumber: faker.randomGenerator.string(12),
      status: AssetStatus.active,
      criticality: AssetCriticality.medium,
      createdAt: faker.date.dateTime(),
      updatedAt: faker.date.dateTime(),
    );
  }

  static List<AssetEntity> makeAssetEntityList() {
    return [makeAssetEntity(), makeAssetEntity(), makeAssetEntity()];
  }

  static UserEntity makeUserEntity() {
    return UserEntity(
      id: faker.guid.guid(),
      name: faker.internet.userName(),
      email: faker.internet.email(),
      isActive: true,
    );
  }

  static User makeUser() {
    return User(
      id: faker.guid.guid(),
      appMetadata: {},
      userMetadata: {},
      aud: faker.randomGenerator.string(5),
      createdAt: faker.date.dateTime().toIso8601String(),
    );
  }

  static UserDataEntity makeUserDataEntity() {
    return UserDataEntity(
      user: makeUserEntity(),
      accessToken: faker.jwt.valid(),
      refreshToken: faker.jwt.valid(),
    );
  }

  static AuthenticationEntity makeAuthentication() {
    return AuthenticationEntity(
      email: faker.internet.userName(),
      password: faker.internet.password(),
    );
  }

  static SignUpEntity makeSignUp() {
    return SignUpEntity(
      name: faker.person.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static AuthenticationRequestModel makeAuthenticationModel() {
    return AuthenticationRequestModel(
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static SignUpRequestModel makeSignUpRequest() {
    return SignUpRequestModel(
      name: faker.person.name(),
      email: faker.internet.email(),
      password: faker.internet.password(),
    );
  }

  static AttachmentEntity makeAttachmentEntity() {
    return AttachmentEntity(
      id: faker.guid.guid(),
      workOrderId: faker.guid.guid(),
      companyId: faker.guid.guid(),
      uploadedById: faker.guid.guid(),
      fileName: faker.company.name(),
      fileType: makeFileType(),
      isCompressed: faker.randomGenerator.boolean(),
      uploadStatus: makeUploadStatus(),
      createdAt: faker.date.dateTime(),
    );
  }

  static FileType makeFileType() =>
      FileType.values[faker.randomGenerator.integer(FileType.values.length)];

  static UploadStatus makeUploadStatus() =>
      UploadStatus.values[faker.randomGenerator.integer(
        UploadStatus.values.length,
      )];

  static CategoryEntity makeCategoryEntity() => CategoryEntity(
    id: faker.guid.guid(),
    companyId: faker.guid.guid(),
    name: faker.company.name(),
    color: faker.randomGenerator.string(7),
    description: faker.lorem.sentence(),
    createdAt: faker.date.dateTime(),
    deletedAt: faker.date.dateTime(),
  );

  static ChecklistTemplateEntity makeChecklistTemplateEntity() =>
      ChecklistTemplateEntity(
        id: faker.guid.guid(),
        companyId: faker.guid.guid(),
        name: faker.company.name(),
        description: faker.lorem.sentence(),
        createdAt: faker.date.dateTime(),
        updatedAt: faker.date.dateTime(),
        categoryId: faker.guid.guid(),
        deletedAt: faker.date.dateTime(),
      );

  static LocationEntity makeLocationEntity() => LocationEntity(
        id: faker.guid.guid(),
        companyId: faker.guid.guid(),
        name: faker.company.name(),
        address: faker.address.streetAddress(),
        city: faker.address.city(),
        state: faker.address.state(),
        isActive: faker.randomGenerator.boolean(),
        createdAt: faker.date.dateTime(),
        updatedAt: faker.date.dateTime(),
        deletedAt: faker.date.dateTime(),
      );

  static List<LocationEntity> makeLocationEntityList() =>
      [makeLocationEntity(), makeLocationEntity(), makeLocationEntity()];

  static MaintenancePlanEntity makeMaintenancePlanEntity() => MaintenancePlanEntity(
        id: faker.guid.guid(),
        companyId: faker.guid.guid(),
        assetId: faker.guid.guid(),
        locationId: faker.guid.guid(),
        title: faker.lorem.word(),
        description: faker.lorem.sentence(),
        frequency: Frequency.values[faker.randomGenerator.integer(Frequency.values.length)],
        dayOfWeek: faker.randomGenerator.integer(7, min: 1),
        dayOfMonth: faker.randomGenerator.integer(28, min: 1),
        monthOfYear: faker.randomGenerator.integer(12, min: 1),
        checklistTemplateId: faker.guid.guid(),
        assignedToId: faker.guid.guid(),
        priority: Priority.values[faker.randomGenerator.integer(Priority.values.length)],
        isActive: faker.randomGenerator.boolean(),
        lastGeneratedAt: faker.date.dateTime(),
        nextDueDate: faker.date.dateTime(),
        createdAt: faker.date.dateTime(),
        updatedAt: faker.date.dateTime(),
        deletedAt: faker.date.dateTime(),
      );

  static List<MaintenancePlanEntity> makeMaintenancePlanEntityList() =>
      [makeMaintenancePlanEntity(), makeMaintenancePlanEntity(), makeMaintenancePlanEntity()];

  static UserProfileEntity makeUserProfileEntity() => UserProfileEntity(
        id: faker.guid.guid(),
        companyId: faker.guid.guid(),
        name: faker.person.name(),
        email: faker.internet.email(),
        phone: faker.randomGenerator.string(10),
        permissionGroupId: faker.guid.guid(),
        avatarUrl: faker.randomGenerator.string(20),
        isActive: faker.randomGenerator.boolean(),
        createdAt: faker.date.dateTime(),
        updatedAt: faker.date.dateTime(),
        deletedAt: faker.date.dateTime(),
      );

  static List<UserProfileEntity> makeUserProfileEntityList() =>
      [makeUserProfileEntity(), makeUserProfileEntity(), makeUserProfileEntity()];
}
