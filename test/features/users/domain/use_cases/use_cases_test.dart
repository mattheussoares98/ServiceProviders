import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/users/domain/entities/permission_group_entity.dart';
import 'package:clean_architecture/features/users/domain/entities/user_profile_entity.dart';
import 'package:clean_architecture/features/users/domain/use_cases/create_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/delete_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/delete_user_profile_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/update_permission_group_use_case.dart';
import 'package:clean_architecture/features/users/domain/use_cases/update_user_profile_use_case.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  late MockUsersRepository mockRepository;

  // Use cases
  late GetUsersUseCase getUsersUseCase;
  late GetUserProfileByIdUseCase getUserProfileByIdUseCase;
  late UpdateUserProfileUseCase updateUserProfileUseCase;
  late DeleteUserProfileUseCase deleteUserProfileUseCase;
  late GetPermissionGroupsUseCase getPermissionGroupsUseCase;
  late CreatePermissionGroupUseCase createPermissionGroupUseCase;
  late UpdatePermissionGroupUseCase updatePermissionGroupUseCase;
  late DeletePermissionGroupUseCase deletePermissionGroupUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeUserProfileEntity());
    registerFallbackValue(EntityFactory.makePermissionGroupEntity());
  });

  setUp(() {
    mockRepository = MockUsersRepository();
    getUsersUseCase = GetUsersUseCase(usersRepository: mockRepository);
    getUserProfileByIdUseCase = GetUserProfileByIdUseCase(usersRepository: mockRepository);
    updateUserProfileUseCase = UpdateUserProfileUseCase(usersRepository: mockRepository);
    deleteUserProfileUseCase = DeleteUserProfileUseCase(usersRepository: mockRepository);
    getPermissionGroupsUseCase = GetPermissionGroupsUseCase(usersRepository: mockRepository);
    createPermissionGroupUseCase = CreatePermissionGroupUseCase(usersRepository: mockRepository);
    updatePermissionGroupUseCase = UpdatePermissionGroupUseCase(usersRepository: mockRepository);
    deletePermissionGroupUseCase = DeletePermissionGroupUseCase(usersRepository: mockRepository);
  });

  final tUserProfileEntity = EntityFactory.makeUserProfileEntity();
  final tUserProfileList = [tUserProfileEntity, tUserProfileEntity, tUserProfileEntity];
  final tPermissionGroupEntity = EntityFactory.makePermissionGroupEntity();
  final tPermissionGroupList = [tPermissionGroupEntity, tPermissionGroupEntity, tPermissionGroupEntity];

  group('User Profiles Use Cases', () {
    group('GetUsersUseCase', () {
      test('should return a list of user profiles on success', () async {
        // Arrange
        final companyId = faker.guid.guid();
        when(() => mockRepository.getUserProfiles(any()))
            .thenAnswer((_) async => SuccessState(data: tUserProfileList));

        // Act
        final result = await getUsersUseCase(companyId);

        // Assert
        expect(result, isA<SuccessState<List<UserProfileEntity>>>());
        expect(result.data, tUserProfileList);
        verify(() => mockRepository.getUserProfiles(companyId)).called(1);
      });
    });

    group('GetUserProfileByIdUseCase', () {
      test('should return user profile by id on success', () async {
        // Arrange
        final userId = faker.guid.guid();
        when(() => mockRepository.getUserProfileById(any()))
            .thenAnswer((_) async => SuccessState(data: tUserProfileEntity));

        // Act
        final result = await getUserProfileByIdUseCase(userId);

        // Assert
        expect(result, isA<SuccessState<UserProfileEntity>>());
        expect(result.data, tUserProfileEntity);
        verify(() => mockRepository.getUserProfileById(userId)).called(1);
      });
    });

    group('UpdateUserProfileUseCase', () {
      test('should update user profile on success', () async {
        // Arrange
        when(() => mockRepository.updateUserProfile(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await updateUserProfileUseCase(tUserProfileEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.updateUserProfile(tUserProfileEntity)).called(1);
      });
    });

    group('DeleteUserProfileUseCase', () {
      test('should delete user profile on success', () async {
        // Arrange
        final userId = faker.guid.guid();
        when(() => mockRepository.deleteUserProfile(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await deleteUserProfileUseCase(userId);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.deleteUserProfile(userId)).called(1);
      });
    });
  });

  group('Permission Groups Use Cases', () {
    group('GetPermissionGroupsUseCase', () {
      test('should return list of permission groups on success', () async {
        // Arrange
        final companyId = faker.guid.guid();
        when(() => mockRepository.getPermissionGroups(any()))
            .thenAnswer((_) async => SuccessState(data: tPermissionGroupList));

        // Act
        final result = await getPermissionGroupsUseCase(companyId);

        // Assert
        expect(result, isA<SuccessState<List<PermissionGroupEntity>>>());
        expect(result.data, tPermissionGroupList);
        verify(() => mockRepository.getPermissionGroups(companyId)).called(1);
      });
    });

    group('CreatePermissionGroupUseCase', () {
      test('should create permission group on success', () async {
        // Arrange
        when(() => mockRepository.createPermissionGroup(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await createPermissionGroupUseCase(tPermissionGroupEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.createPermissionGroup(tPermissionGroupEntity)).called(1);
      });
    });

    group('UpdatePermissionGroupUseCase', () {
      test('should update permission group on success', () async {
        // Arrange
        when(() => mockRepository.updatePermissionGroup(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await updatePermissionGroupUseCase(tPermissionGroupEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.updatePermissionGroup(tPermissionGroupEntity)).called(1);
      });
    });

    group('DeletePermissionGroupUseCase', () {
      test('should delete permission group on success', () async {
        // Arrange
        final groupId = faker.guid.guid();
        when(() => mockRepository.deletePermissionGroup(any()))
            .thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await deletePermissionGroupUseCase(groupId);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(() => mockRepository.deletePermissionGroup(groupId)).called(1);
      });
    });
  });
}
