import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/storage/storage_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/invite_user_params.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/create_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/delete_user_profile_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_permission_groups_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_user_profile_by_id_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/get_users_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/invite_user_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/resend_invitation_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_permission_group_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_avatar_use_case.dart';
import 'package:o_jogo_da_obra/features/users/domain/use_cases/update_user_profile_use_case.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/external/external_mocks.dart';
import '../../../../../testing/mocks/repository_mocks.dart';
import '../../../../../testing/mocks/services.dart';
import '../../../../../testing/mocks/use_case_mocks.dart';

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
  late InviteUserUseCase inviteUserUseCase;
  late ResendInvitationUseCase resendInvitationUseCase;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeUserProfileEntity());
    registerFallbackValue(EntityFactory.makePermissionGroupEntity());
    registerFallbackValue(EntityFactory.makeUserInvitationEntity());
    registerFallbackValue(
      const InviteUserParams(email: '', companyId: '', groupId: ''),
    );
  });

  setUp(() {
    mockRepository = MockUsersRepository();
    getUsersUseCase = GetUsersUseCase(usersRepository: mockRepository);
    getUserProfileByIdUseCase = GetUserProfileByIdUseCase(
      usersRepository: mockRepository,
    );
    updateUserProfileUseCase = UpdateUserProfileUseCase(
      usersRepository: mockRepository,
    );
    deleteUserProfileUseCase = DeleteUserProfileUseCase(
      usersRepository: mockRepository,
    );
    getPermissionGroupsUseCase = GetPermissionGroupsUseCase(
      usersRepository: mockRepository,
    );
    createPermissionGroupUseCase = CreatePermissionGroupUseCase(
      usersRepository: mockRepository,
    );
    updatePermissionGroupUseCase = UpdatePermissionGroupUseCase(
      usersRepository: mockRepository,
    );
    deletePermissionGroupUseCase = DeletePermissionGroupUseCase(
      usersRepository: mockRepository,
    );
    inviteUserUseCase = InviteUserUseCase(usersRepository: mockRepository);
    resendInvitationUseCase = ResendInvitationUseCase(
      usersRepository: mockRepository,
    );
  });

  final tUserProfileEntity = EntityFactory.makeUserProfileEntity();
  final tUserProfileList = [
    tUserProfileEntity,
    tUserProfileEntity,
    tUserProfileEntity,
  ];
  final tPermissionGroupEntity = EntityFactory.makePermissionGroupEntity();
  final tPermissionGroupList = [
    tPermissionGroupEntity,
    tPermissionGroupEntity,
    tPermissionGroupEntity,
  ];

  group('User Profiles Use Cases', () {
    group('GetUsersUseCase', () {
      test('should return a list of user profiles on success', () async {
        // Arrange
        final companyId = faker.guid.guid();
        when(
          () => mockRepository.getUserProfiles(any()),
        ).thenAnswer((_) async => SuccessState(data: tUserProfileList));

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
        when(
          () => mockRepository.getUserProfileById(any()),
        ).thenAnswer((_) async => SuccessState(data: tUserProfileEntity));

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
        when(
          () => mockRepository.updateUserProfile(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await updateUserProfileUseCase(tUserProfileEntity);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockRepository.updateUserProfile(tUserProfileEntity),
        ).called(1);
      });
    });

    group('DeleteUserProfileUseCase', () {
      test('should delete user profile on success', () async {
        // Arrange
        final userId = faker.guid.guid();
        when(
          () => mockRepository.deleteUserProfile(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await deleteUserProfileUseCase(userId);

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
      });
    });

    group('InviteUserUseCase', () {
      test('should invite user on success', () async {
        // Arrange
        final email = faker.internet.email();
        final companyId = faker.guid.guid();
        final groupId = faker.guid.guid();
        final params = InviteUserParams(
          email: email,
          companyId: companyId,
          groupId: groupId,
        );

        when(
          () => mockRepository.inviteUser(
            email: any(named: 'email'),
            companyId: any(named: 'companyId'),
            groupId: any(named: 'groupId'),
          ),
        ).thenAnswer((_) async => SuccessState.nil);

        // Act
        final result = await inviteUserUseCase(params);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockRepository.inviteUser(
            email: email,
            companyId: companyId,
            groupId: groupId,
          ),
        ).called(1);
      });
    });

    group('ResendInvitationUseCase', () {
      test('should resend invitation on success', () async {
        // Arrange
        final invitation = EntityFactory.makeUserInvitationEntity();
        when(
          () => mockRepository.resendInvitation(any()),
        ).thenAnswer((_) async => SuccessState.nil);

        // Act
        final result = await resendInvitationUseCase(invitation);

        // Assert
        expect(result, isA<SuccessState<void>>());
        verify(() => mockRepository.resendInvitation(invitation)).called(1);
      });
    });

    group('UpdateUserAvatarUseCase', () {
      late MockStorageClient mockStorage;
      late MockSetSessionUseCase mockSetSession;
      late MockSaveUserDataUseCase mockSaveUserData;
      late MockSupabaseAuthClient mockAuth;
      late MockFileService mockFileService;
      late UpdateUserAvatarUseCase updateUserAvatarUseCase;

      setUp(() {
        mockStorage = MockStorageClient();
        mockSetSession = MockSetSessionUseCase();
        mockSaveUserData = MockSaveUserDataUseCase();
        mockAuth = MockSupabaseAuthClient();
        mockFileService = MockFileService();
        updateUserAvatarUseCase = UpdateUserAvatarUseCase(
          storageClient: mockStorage,
          usersRepository: mockRepository,
          setSession: mockSetSession,
          saveUserData: mockSaveUserData,
          authClient: mockAuth,
          fileService: mockFileService,
        );
      });

      test(
        'should successfully upload avatar and update profile and session',
        () async {
          final localPath = '${faker.lorem.word()}.jpg';
          final params = UpdateUserAvatarParams(
            userProfile: tUserProfileEntity,
            localPath: localPath,
          );

          when(
            () => mockFileService.getMimeType(any()),
          ).thenReturn('image/jpeg');
          when(() => mockStorage.getPresignedUploadUrl(any())).thenAnswer(
            (_) async => const SuccessState(
              data: PresignedUrlResponse(
                uploadUrl: 'http://upload',
                fileKey: 'key',
                publicUrl: 'http://public',
              ),
            ),
          );
          when(
            () => mockStorage.uploadFile(
              presignedUrl: any(named: 'presignedUrl'),
              filePath: any(named: 'filePath'),
              mimeType: any(named: 'mimeType'),
            ),
          ).thenAnswer((_) async => const SuccessState(data: 'http://public'));

          when(
            () => mockRepository.updateUserProfile(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));
          when(() => mockAuth.currentSession).thenReturn(null);
          when(
            () => mockSaveUserData.call(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final result = await updateUserAvatarUseCase(params);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);

          verify(() => mockFileService.getMimeType(localPath)).called(1);
          verify(() => mockStorage.getPresignedUploadUrl(any())).called(1);
          verify(
            () => mockStorage.uploadFile(
              presignedUrl: 'http://upload',
              filePath: localPath,
              mimeType: 'image/jpeg',
            ),
          ).called(1);
          verify(() => mockRepository.updateUserProfile(any())).called(1);
          verify(() => mockSetSession.call(any())).called(1);
          verify(() => mockSaveUserData.call(any())).called(1);
        },
      );

      test(
        'should return FailureState when getPresignedUploadUrl fails',
        () async {
          final localPath = '${faker.lorem.word()}.jpg';
          final params = UpdateUserAvatarParams(
            userProfile: tUserProfileEntity,
            localPath: localPath,
          );

          when(
            () => mockFileService.getMimeType(any()),
          ).thenReturn('image/jpeg');
          when(
            () => mockStorage.getPresignedUploadUrl(any()),
          ).thenAnswer((_) async => FailureState(message: 'presigned error'));

          final result = await updateUserAvatarUseCase(params);

          expect(result, isA<FailureState<bool>>());
          expect((result as FailureState).message, 'presigned error');
          verifyNever(
            () => mockStorage.uploadFile(
              presignedUrl: any(named: 'presignedUrl'),
              filePath: any(named: 'filePath'),
              mimeType: any(named: 'mimeType'),
            ),
          );
        },
      );
    });
  });

  group('Permission Groups Use Cases', () {
    group('GetPermissionGroupsUseCase', () {
      test('should return list of permission groups on success', () async {
        // Arrange
        final companyId = faker.guid.guid();
        when(
          () => mockRepository.getPermissionGroups(any()),
        ).thenAnswer((_) async => SuccessState(data: tPermissionGroupList));

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
        when(
          () => mockRepository.createPermissionGroup(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await createPermissionGroupUseCase(
          tPermissionGroupEntity,
        );

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockRepository.createPermissionGroup(tPermissionGroupEntity),
        ).called(1);
      });
    });

    group('UpdatePermissionGroupUseCase', () {
      test('should update permission group on success', () async {
        // Arrange
        when(
          () => mockRepository.updatePermissionGroup(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        // Act
        final result = await updatePermissionGroupUseCase(
          tPermissionGroupEntity,
        );

        // Assert
        expect(result, isA<SuccessState<bool>>());
        expect(result.data, isTrue);
        verify(
          () => mockRepository.updatePermissionGroup(tPermissionGroupEntity),
        ).called(1);
      });
    });

    group('DeletePermissionGroupUseCase', () {
      test('should delete permission group on success', () async {
        // Arrange
        final groupId = faker.guid.guid();
        when(
          () => mockRepository.deletePermissionGroup(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

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
