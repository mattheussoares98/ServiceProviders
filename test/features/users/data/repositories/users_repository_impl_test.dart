import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:clean_architecture/features/users/data/repositories/users_repository_impl.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockUsersRemoteDataSource mockRemoteDataSource;
  late MockUsersLocalDataSource mockLocalDataSource;
  late UsersRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      UserProfileResponseModel.fromEntity(EntityFactory.makeUserProfileEntity()),
    );
    registerFallbackValue(
      PermissionGroupResponseModel.fromEntity(EntityFactory.makePermissionGroupEntity()),
    );
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockUsersRemoteDataSource();
    mockLocalDataSource = MockUsersLocalDataSource();
    repository = UsersRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tUserProfileEntity = EntityFactory.makeUserProfileEntity();
  final tUserProfileModel = UserProfileResponseModel.fromEntity(tUserProfileEntity);
  final tUserProfileList = [tUserProfileEntity, tUserProfileEntity, tUserProfileEntity];
  final tUserProfileModelList = tUserProfileList.map(UserProfileResponseModel.fromEntity).toList();

  final tPermissionGroupEntity = EntityFactory.makePermissionGroupEntity();
  final tPermissionGroupModel = PermissionGroupResponseModel.fromEntity(tPermissionGroupEntity);
  final tPermissionGroupList = [tPermissionGroupEntity, tPermissionGroupEntity, tPermissionGroupEntity];
  final tPermissionGroupModelList = tPermissionGroupList.map(PermissionGroupResponseModel.fromEntity).toList();

  group('UsersRepositoryImpl', () {
    group('User Profiles', () {
      test('should return list of user profiles from local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.getUserProfiles(any()))
            .thenAnswer((_) async => SuccessState(data: tUserProfileModelList));

        // Act
        final result = await repository.getUserProfiles(faker.guid.guid());

        // Assert
        expect(result, isA<SuccessState<List<UserProfileEntity>>>());
        expect(result.data, hasLength(3));
        expect(result.data!.first, equals(tUserProfileEntity));
        verify(() => mockLocalDataSource.getUserProfiles(any())).called(1);
      });

      test('should return user profile by id from local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.getUserProfileById(any()))
            .thenAnswer((_) async => SuccessState(data: tUserProfileModel));

        // Act
        final result = await repository.getUserProfileById(tUserProfileModel.id);

        // Assert
        expect(result, isA<SuccessState<UserProfileEntity>>());
        expect(result.data, equals(tUserProfileEntity));
        verify(() => mockLocalDataSource.getUserProfileById(tUserProfileModel.id)).called(1);
      });

      test('should update user profile in local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.saveUserProfile(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.updateUserProfile(tUserProfileEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.saveUserProfile(any())).called(1);
      });

      test('should delete user profile in local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.deleteUserProfile(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deleteUserProfile(tUserProfileModel.id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.deleteUserProfile(tUserProfileModel.id)).called(1);
      });
    });

    group('Permission Groups', () {
      test('should return list of permission groups from local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.getPermissionGroups(any()))
            .thenAnswer((_) async => SuccessState(data: tPermissionGroupModelList));

        // Act
        final result = await repository.getPermissionGroups(faker.guid.guid());

        // Assert
        expect(result, isA<SuccessState<List<PermissionGroupEntity>>>());
        expect(result.data, hasLength(3));
        expect(result.data!.first, equals(tPermissionGroupEntity));
        verify(() => mockLocalDataSource.getPermissionGroups(any())).called(1);
      });

      test('should create permission group in local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.savePermissionGroup(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.createPermissionGroup(tPermissionGroupEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.savePermissionGroup(any())).called(1);
      });

      test('should update permission group in local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.savePermissionGroup(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.updatePermissionGroup(tPermissionGroupEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.savePermissionGroup(any())).called(1);
      });

      test('should delete permission group in local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.deletePermissionGroup(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await repository.deletePermissionGroup(tPermissionGroupModel.id);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockLocalDataSource.deletePermissionGroup(tPermissionGroupModel.id)).called(1);
      });
    });
  });
}
