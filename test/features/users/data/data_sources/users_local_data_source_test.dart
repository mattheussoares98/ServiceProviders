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
    await database
        .into(database.companies)
        .insert(
          CompaniesCompanion.insert(
            id: companyId,
            name: faker.company.name(),
            isActive: const Value(true),
          ),
        );
  }

  Future<void> openAndCloseDatabase() async {
    await database.customSelect('SELECT 1').get();
    await database.close();
  }

  final tUserProfileEntity = EntityFactory.makeUserProfileEntity().copyWith(
    annulPermissionGroupId: true,
  );
  final tUserProfileModel = UserProfileResponseModel.fromEntity(
    tUserProfileEntity,
  );

  final tPermissionGroupEntity = EntityFactory.makePermissionGroupEntity();
  final tPermissionGroupModel = PermissionGroupResponseModel.fromEntity(
    tPermissionGroupEntity,
  );

  group('UsersLocalDataSourceImpl', () {
    group('User Profiles', () {
      test('should retrieve all user profiles for a company', () async {
        await insertTestCompany(tUserProfileModel.companyId);
        await dataSource.saveUserProfile(tUserProfileModel);

        final result = await dataSource.getUserProfiles(
          tUserProfileModel.companyId,
        );

        expect(result, isA<SuccessState<List<UserProfileResponseModel>>>());
        expect(result.data, hasLength(1));
        expect(result.data!.first, equals(tUserProfileModel));
      });

      test(
        'should retrieve only user profiles for the specified company',
        () async {
          final otherCompanyId = faker.guid.guid();
          final otherProfileEntity = EntityFactory.makeUserProfileEntity()
              .copyWith(
                companyId: otherCompanyId,
                annulPermissionGroupId: true,
              );
          final otherProfileModel = UserProfileResponseModel.fromEntity(
            otherProfileEntity,
          );

          await insertTestCompany(tUserProfileModel.companyId);
          await insertTestCompany(otherCompanyId);

          await dataSource.saveUserProfile(tUserProfileModel);
          await dataSource.saveUserProfile(otherProfileModel);

          final result = await dataSource.getUserProfiles(
            tUserProfileModel.companyId,
          );

          expect(result, isA<SuccessState<List<UserProfileResponseModel>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tUserProfileModel));
        },
      );

      test(
        'should return empty list when no user profiles exist for that company',
        () async {
          final result = await dataSource.getUserProfiles(faker.guid.guid());

          expect(result, isA<SuccessState<List<UserProfileResponseModel>>>());
          expect(result.data, isEmpty);
        },
      );

      test(
        'should return FailureState when database throws an exception on getUserProfiles',
        () async {
          await openAndCloseDatabase();

          final result = await dataSource.getUserProfiles(
            tUserProfileModel.companyId,
          );

          expect(result, isA<FailureState<List<UserProfileResponseModel>>>());
        },
      );

      test('should save a user profile and successfully retrieve it', () async {
        await insertTestCompany(tUserProfileModel.companyId);

        final saveResult = await dataSource.saveUserProfile(tUserProfileModel);

        expect(saveResult, isA<SuccessState<bool>>());
        expect(saveResult.data, isTrue);

        final getResult = await dataSource.getUserProfileById(
          tUserProfileModel.id,
        );

        expect(getResult, isA<SuccessState<UserProfileResponseModel>>());
        expect(getResult.data, equals(tUserProfileModel));
      });

      test(
        'should return FailureState when getting a non-existent user profile',
        () async {
          final result = await dataSource.getUserProfileById(faker.guid.guid());

          expect(result, isA<FailureState<UserProfileResponseModel>>());
        },
      );

      test(
        'should return FailureState when database throws an exception on getUserProfileById',
        () async {
          await openAndCloseDatabase();

          final result = await dataSource.getUserProfileById(
            tUserProfileModel.id,
          );

          expect(result, isA<FailureState<UserProfileResponseModel>>());
        },
      );

      test(
        'should return FailureState when database throws an exception on saveUserProfile',
        () async {
          await openAndCloseDatabase();

          final result = await dataSource.saveUserProfile(tUserProfileModel);

          expect(result, isA<FailureState<bool>>());
        },
      );

      test(
        'should soft-delete a user profile and verify it is not returned',
        () async {
          await insertTestCompany(tUserProfileModel.companyId);
          await dataSource.saveUserProfile(tUserProfileModel);

          final deleteResult = await dataSource.deleteUserProfile(
            tUserProfileModel.id,
          );

          expect(deleteResult, isA<SuccessState<bool>>());
          expect(deleteResult.data, isTrue);

          final getResult = await dataSource.getUserProfileById(
            tUserProfileModel.id,
          );

          expect(getResult, isA<FailureState<UserProfileResponseModel>>());
        },
      );

      test(
        'should return FailureState when database throws an exception on deleteUserProfile',
        () async {
          await openAndCloseDatabase();

          final result = await dataSource.deleteUserProfile(
            tUserProfileModel.id,
          );

          expect(result, isA<FailureState<bool>>());
        },
      );
    });

    group('Permission Groups', () {
      test(
        'should save a permission group and successfully retrieve it',
        () async {
          await insertTestCompany(tPermissionGroupModel.companyId);

          final saveResult = await dataSource.savePermissionGroup(
            tPermissionGroupModel,
          );

          expect(saveResult, isA<SuccessState<bool>>());
          expect(saveResult.data, isTrue);

          final getResult = await dataSource.getPermissionGroups(
            tPermissionGroupModel.companyId,
          );

          expect(
            getResult,
            isA<SuccessState<List<PermissionGroupResponseModel>>>(),
          );
          expect(getResult.data, hasLength(1));
          expect(getResult.data!.first, equals(tPermissionGroupModel));
        },
      );

      test(
        'should retrieve only permission groups for the specified company',
        () async {
          final otherCompanyId = faker.guid.guid();
          final otherGroupEntity = EntityFactory.makePermissionGroupEntity()
              .copyWith(companyId: otherCompanyId);
          final otherGroupModel = PermissionGroupResponseModel.fromEntity(
            otherGroupEntity,
          );

          await insertTestCompany(tPermissionGroupModel.companyId);
          await insertTestCompany(otherCompanyId);

          await dataSource.savePermissionGroup(tPermissionGroupModel);
          await dataSource.savePermissionGroup(otherGroupModel);

          final result = await dataSource.getPermissionGroups(
            tPermissionGroupModel.companyId,
          );

          expect(
            result,
            isA<SuccessState<List<PermissionGroupResponseModel>>>(),
          );
          expect(result.data, hasLength(1));
          expect(result.data!.first, equals(tPermissionGroupModel));
        },
      );

      test(
        'should return empty list when no permission groups exist for that company',
        () async {
          final result = await dataSource.getPermissionGroups(
            faker.guid.guid(),
          );

          expect(
            result,
            isA<SuccessState<List<PermissionGroupResponseModel>>>(),
          );
          expect(result.data, isEmpty);
        },
      );

      test(
        'should return FailureState when database throws an exception on getPermissionGroups',
        () async {
          await openAndCloseDatabase();

          final result = await dataSource.getPermissionGroups(
            tPermissionGroupModel.companyId,
          );

          expect(
            result,
            isA<FailureState<List<PermissionGroupResponseModel>>>(),
          );
        },
      );

      test(
        'should return FailureState when database throws an exception on savePermissionGroup',
        () async {
          await openAndCloseDatabase();

          final result = await dataSource.savePermissionGroup(
            tPermissionGroupModel,
          );

          expect(result, isA<FailureState<bool>>());
        },
      );

      test(
        'should soft-delete a permission group and verify it is not returned',
        () async {
          await insertTestCompany(tPermissionGroupModel.companyId);
          await dataSource.savePermissionGroup(tPermissionGroupModel);

          final deleteResult = await dataSource.deletePermissionGroup(
            tPermissionGroupModel.id,
          );

          expect(deleteResult, isA<SuccessState<bool>>());
          expect(deleteResult.data, isTrue);

          final getResult = await dataSource.getPermissionGroups(
            tPermissionGroupModel.companyId,
          );

          expect(
            getResult,
            isA<SuccessState<List<PermissionGroupResponseModel>>>(),
          );
          expect(getResult.data, isEmpty);
        },
      );

      test(
        'should return FailureState when database throws an exception on deletePermissionGroup',
        () async {
          await openAndCloseDatabase();

          final result = await dataSource.deletePermissionGroup(
            tPermissionGroupModel.id,
          );

          expect(result, isA<FailureState<bool>>());
        },
      );
    });
  });
}
