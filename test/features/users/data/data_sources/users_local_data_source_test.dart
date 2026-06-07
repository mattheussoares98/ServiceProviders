import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_local_data_source.dart';
import 'package:clean_architecture/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late AppDatabase database;
  late UsersLocalDataSourceImpl dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = UsersLocalDataSourceImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertTestCompany(String companyId) async {
    await database.into(database.companies).insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );
  }

  final tUserProfileEntity = EntityFactory.makeUserProfileEntity().annulPermissionGroupId();
  final tUserProfileModel = UserProfileResponseModel.fromEntity(tUserProfileEntity);

  final tPermissionGroupEntity = EntityFactory.makePermissionGroupEntity();
  final tPermissionGroupModel = PermissionGroupResponseModel.fromEntity(tPermissionGroupEntity);

  group('UsersLocalDataSourceImpl', () {
    group('User Profiles', () {
      test('should retrieve all user profiles for a company', () async {
        // Arrange
        await insertTestCompany(tUserProfileModel.companyId);
        await dataSource.saveUserProfile(tUserProfileModel);

        // Act
        final result = await dataSource.getUserProfiles(tUserProfileModel.companyId);

        // Assert
        expect(result, isA<SuccessState<List<UserProfileResponseModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first, equals(tUserProfileModel));
      });

      test('should save a user profile and successfully retrieve it', () async {
        // Arrange
        await insertTestCompany(tUserProfileModel.companyId);

        // Act: Save
        final saveResult = await dataSource.saveUserProfile(tUserProfileModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get
        final getResult = await dataSource.getUserProfileById(tUserProfileModel.id);

        // Assert Get
        expect(getResult, isA<SuccessState<UserProfileResponseModel>>());
        expect(getResult.data, equals(tUserProfileModel));
      });

      test('should return FailureState when getting a non-existent user profile', () async {
        // Act
        final result = await dataSource.getUserProfileById(faker.guid.guid());

        // Assert
        expect(result, isA<FailureState<UserProfileResponseModel>>());
      });

      test('should soft-delete a user profile and verify it is not returned', () async {
        // Arrange
        await insertTestCompany(tUserProfileModel.companyId);
        await dataSource.saveUserProfile(tUserProfileModel);

        // Act: Delete
        final deleteResult = await dataSource.deleteUserProfile(tUserProfileModel.id);

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get
        final getResult = await dataSource.getUserProfileById(tUserProfileModel.id);

        // Assert Get: Should fail
        expect(getResult, isA<FailureState<UserProfileResponseModel>>());
      });
    });

    group('Permission Groups', () {
      test('should save a permission group and successfully retrieve it', () async {
        // Arrange
        await insertTestCompany(tPermissionGroupModel.companyId);

        // Act: Save
        final saveResult = await dataSource.savePermissionGroup(tPermissionGroupModel);

        // Assert Save
        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        // Act: Get
        final getResult = await dataSource.getPermissionGroups(tPermissionGroupModel.companyId);

        // Assert Get
        expect(getResult, isA<SuccessState<List<PermissionGroupResponseModel>>>());
        expect(getResult.data, hasLength(1));
        expect(getResult.data!.first, equals(tPermissionGroupModel));
      });

      test('should soft-delete a permission group and verify it is not returned', () async {
        // Arrange
        await insertTestCompany(tPermissionGroupModel.companyId);
        await dataSource.savePermissionGroup(tPermissionGroupModel);

        // Act: Delete
        final deleteResult = await dataSource.deletePermissionGroup(tPermissionGroupModel.id);

        // Assert Delete
        expect(deleteResult, isA<SuccessState<bool>>());
        expect(deleteResult.data, isTrue);

        // Act: Get
        final getResult = await dataSource.getPermissionGroups(tPermissionGroupModel.companyId);

        // Assert Get: Should be empty
        expect(getResult, isA<SuccessState<List<PermissionGroupResponseModel>>>());
        expect(getResult.data, isEmpty);
      });
    });
  });
}
