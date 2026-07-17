import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_invitation_response_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:o_jogo_da_obra/features/users/data/repositories/users_repository_impl.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';

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
      UserProfileResponseModel.fromEntity(
        EntityFactory.makeUserProfileEntity(),
      ),
    );
    registerFallbackValue(
      PermissionGroupModel.fromEntity(
        EntityFactory.makePermissionGroupEntity(),
      ),
    );
    registerFallbackValue(
      UserInvitationResponseModel.fromEntity(
        EntityFactory.makeUserInvitationEntity(),
      ),
    );
    registerFallbackValue(<UserProfileResponseModel>[]);
    registerFallbackValue(<PermissionGroupModel>[]);
    registerFallbackValue(<UserInvitationResponseModel>[]);
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
  final tUserProfileModel = UserProfileResponseModel.fromEntity(
    tUserProfileEntity,
  );
  final tUserProfileList = [
    tUserProfileEntity,
    tUserProfileEntity,
    tUserProfileEntity,
  ];
  final tUserProfileModelList = tUserProfileList
      .map(UserProfileResponseModel.fromEntity)
      .toList();

  final tPermissionGroupEntity = EntityFactory.makePermissionGroupEntity();
  final tPermissionGroupModel = PermissionGroupModel.fromEntity(
    tPermissionGroupEntity,
  );
  final tPermissionGroupList = [
    tPermissionGroupEntity,
    tPermissionGroupEntity,
    tPermissionGroupEntity,
  ];
  final tPermissionGroupModelList = tPermissionGroupList
      .map(PermissionGroupModel.fromEntity)
      .toList();

  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  group('UsersRepositoryImpl', () {
    group('User Profiles', () {
      group('getUserProfiles', () {
        test(
          'should fetch profiles from remote, cache them locally, and return list on success when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(() => mockRemoteDataSource.getUserProfiles(any())).thenAnswer(
              (_) async => SuccessState(data: tUserProfileModelList),
            );
            when(
              () => mockLocalDataSource.saveUserProfiles(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.getUserProfiles(tCompanyId);

            expect(result, isA<SuccessState<List<UserProfileEntity>>>());
            expect(result.data, hasLength(3));
            expect(result.data!.first, equals(tUserProfileEntity));
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.getUserProfiles(tCompanyId),
            ).called(1);
            verify(
              () => mockLocalDataSource.saveUserProfiles(tUserProfileModelList),
            ).called(1);
            verifyNever(() => mockLocalDataSource.getUserProfiles(any()));
          },
        );

        test(
          'should return list of UserProfileEntity from local when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(() => mockLocalDataSource.getUserProfiles(any())).thenAnswer(
              (_) async => SuccessState(data: tUserProfileModelList),
            );

            final result = await repository.getUserProfiles(tCompanyId);

            expect(result, isA<SuccessState<List<UserProfileEntity>>>());
            expect(result.data, hasLength(3));
            expect(result.data!.first, equals(tUserProfileEntity));
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockLocalDataSource.getUserProfiles(tCompanyId),
            ).called(1);
            verifyNever(() => mockRemoteDataSource.getUserProfiles(any()));
            verifyNever(() => mockLocalDataSource.saveUserProfiles(any()));
          },
        );
      });

      group('getUserProfileById', () {
        test(
          'should fetch profile from remote, cache locally, and return it when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.getUserProfileById(any()),
            ).thenAnswer((_) async => SuccessState(data: tUserProfileModel));
            when(
              () => mockLocalDataSource.saveUserProfile(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.getUserProfileById(tId);

            expect(result, isA<SuccessState<UserProfileEntity>>());
            expect(result.data, equals(tUserProfileEntity));
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.getUserProfileById(tId),
            ).called(1);
            verify(
              () => mockLocalDataSource.saveUserProfile(tUserProfileModel),
            ).called(1);
            verifyNever(() => mockLocalDataSource.getUserProfileById(any()));
          },
        );

        test(
          'should return UserProfileEntity from local when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.getUserProfileById(any()),
            ).thenAnswer((_) async => SuccessState(data: tUserProfileModel));

            final result = await repository.getUserProfileById(tId);

            expect(result, isA<SuccessState<UserProfileEntity>>());
            expect(result.data, equals(tUserProfileEntity));
            verify(() => mockInternetClient.isConnected).called(1);
            verify(() => mockLocalDataSource.getUserProfileById(tId)).called(1);
            verifyNever(() => mockRemoteDataSource.getUserProfileById(any()));
            verifyNever(() => mockLocalDataSource.saveUserProfile(any()));
          },
        );
      });

      group('updateUserProfile', () {
        test(
          'should not save profile locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.saveUserProfile(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.updateUserProfile(
              tUserProfileEntity,
            );

            expect(result, isA<FailureState<bool>>());
            verify(() => mockInternetClient.isConnected).called(1);
            verifyNever(
              () => mockLocalDataSource.saveUserProfile(tUserProfileModel),
            );
            verifyNever(() => mockRemoteDataSource.updateUserProfile(any()));
          },
        );

        test(
          'should update profile remotely, save locally, and return true when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.updateUserProfile(any()),
            ).thenAnswer((_) async => SuccessState(data: tUserProfileModel));
            when(
              () => mockLocalDataSource.saveUserProfile(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.updateUserProfile(
              tUserProfileEntity,
            );

            expect(result, isA<SuccessState<bool>>());
            expect(result.data, isTrue);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.updateUserProfile(any()),
            ).called(1);
            verify(
              () => mockLocalDataSource.saveUserProfile(tUserProfileModel),
            ).called(1);
          },
        );
      });

      group('deleteUserProfile', () {
        test(
          'should not delete profile locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.deleteUserProfile(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.deleteUserProfile(tId);

            expect(result, isA<FailureState<bool>>());
            verify(() => mockInternetClient.isConnected).called(1);
            verifyNever(() => mockLocalDataSource.deleteUserProfile(tId));
            verifyNever(() => mockRemoteDataSource.deleteUserProfile(any()));
          },
        );

        test(
          'should delete profile remotely, delete locally, and return true when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.deleteUserProfile(any()),
            ).thenAnswer((_) async => SuccessState.nil);
            when(
              () => mockLocalDataSource.deleteUserProfile(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.deleteUserProfile(tId);

            expect(result, isA<SuccessState<bool>>());
            expect(result.data, isTrue);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(() => mockRemoteDataSource.deleteUserProfile(tId)).called(1);
            verify(() => mockLocalDataSource.deleteUserProfile(tId)).called(1);
          },
        );
      });

      group('inviteUser', () {
        test('should not call remote when offline', () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);

          final result = await repository.inviteUser(
            email: faker.internet.email(),
            companyId: tCompanyId,
            groupId: tId,
          );

          expect(result, isA<FailureState<void>>());
          verify(() => mockInternetClient.isConnected).called(1);
          verifyNever(
            () => mockRemoteDataSource.inviteUser(
              email: any(named: 'email'),
              companyId: any(named: 'companyId'),
              groupId: any(named: 'groupId'),
            ),
          );
        });

        test('should call remote and return success when online', () async {
          final email = faker.internet.email();
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.inviteUser(
              email: any(named: 'email'),
              companyId: any(named: 'companyId'),
              groupId: any(named: 'groupId'),
            ),
          ).thenAnswer((_) async => SuccessState.nil);

          final result = await repository.inviteUser(
            email: email,
            companyId: tCompanyId,
            groupId: tId,
          );

          expect(result, isA<SuccessState<void>>());
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.inviteUser(
              email: email,
              companyId: tCompanyId,
              groupId: tId,
            ),
          ).called(1);
        });
      });

      group('getPendingInvitations', () {
        test('should not call remote when offline', () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);

          final result = await repository.getPendingInvitations(tCompanyId);

          expect(result, isA<FailureState<List<UserInvitationEntity>>>());
          verify(() => mockInternetClient.isConnected).called(1);
          verifyNever(() => mockRemoteDataSource.getPendingInvitations(any()));
        });

        test(
          'should call remote and map to entities on success when online',
          () async {
            final tInvitationModel = UserInvitationResponseModel.fromEntity(
              EntityFactory.makeUserInvitationEntity(),
            );
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.getPendingInvitations(any()),
            ).thenAnswer((_) async => SuccessState(data: [tInvitationModel]));

            final result = await repository.getPendingInvitations(tCompanyId);

            expect(result, isA<SuccessState<List<UserInvitationEntity>>>());
            expect(result.data, hasLength(1));
            expect(result.data!.first.id, tInvitationModel.id);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.getPendingInvitations(tCompanyId),
            ).called(1);
          },
        );
      });

      group('revokeInvitation', () {
        test('should not call remote when offline', () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);

          final result = await repository.revokeInvitation(tId);

          expect(result, isA<FailureState<bool>>());
          verify(() => mockInternetClient.isConnected).called(1);
          verifyNever(() => mockRemoteDataSource.revokeInvitation(any()));
        });

        test('should call remote and return success when online', () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.revokeInvitation(any()),
          ).thenAnswer((_) async => SuccessState.nil);

          final result = await repository.revokeInvitation(tId);

          expect(result, isA<SuccessState<bool>>());
          expect(result.data, isTrue);
          verify(() => mockInternetClient.isConnected).called(1);
          verify(() => mockRemoteDataSource.revokeInvitation(tId)).called(1);
        });
      });

      group('resendInvitation', () {
        final tInvitation = EntityFactory.makeUserInvitationEntity();

        test('should not call remote when offline', () async {
          when(() => mockInternetClient.isConnected).thenReturn(false);

          final result = await repository.resendInvitation(tInvitation);

          expect(result, isA<FailureState<void>>());
          verify(() => mockInternetClient.isConnected).called(1);
          verifyNever(() => mockRemoteDataSource.resendInvitation(any()));
        });

        test('should call remote and return success when online', () async {
          when(() => mockInternetClient.isConnected).thenReturn(true);
          when(
            () => mockRemoteDataSource.resendInvitation(any()),
          ).thenAnswer((_) async => SuccessState.nil);

          final result = await repository.resendInvitation(tInvitation);

          expect(result, isA<SuccessState<void>>());
          verify(() => mockInternetClient.isConnected).called(1);
          verify(
            () => mockRemoteDataSource.resendInvitation(tInvitation),
          ).called(1);
        });
      });
    });

    group('Permission Groups', () {
      group('getPermissionGroups', () {
        test(
          'should fetch groups from remote, cache locally, and return list on success when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.getPermissionGroups(any()),
            ).thenAnswer(
              (_) async => SuccessState(data: tPermissionGroupModelList),
            );
            when(
              () => mockLocalDataSource.savePermissionGroups(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.getPermissionGroups(tCompanyId);

            expect(result, isA<SuccessState<List<PermissionGroupEntity>>>());
            expect(result.data, hasLength(3));
            expect(result.data!.first, equals(tPermissionGroupEntity));
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.getPermissionGroups(tCompanyId),
            ).called(1);
            verify(
              () => mockLocalDataSource.savePermissionGroups(
                tPermissionGroupModelList,
              ),
            ).called(1);
            verifyNever(() => mockLocalDataSource.getPermissionGroups(any()));
          },
        );

        test(
          'should return list of PermissionGroupEntity from local when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.getPermissionGroups(any()),
            ).thenAnswer(
              (_) async => SuccessState(data: tPermissionGroupModelList),
            );

            final result = await repository.getPermissionGroups(tCompanyId);

            expect(result, isA<SuccessState<List<PermissionGroupEntity>>>());
            expect(result.data, hasLength(3));
            expect(result.data!.first, equals(tPermissionGroupEntity));
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockLocalDataSource.getPermissionGroups(tCompanyId),
            ).called(1);
            verifyNever(() => mockRemoteDataSource.getPermissionGroups(any()));
            verifyNever(() => mockLocalDataSource.savePermissionGroups(any()));
          },
        );
      });

      group('createPermissionGroup', () {
        test(
          'should not save group locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.savePermissionGroup(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.createPermissionGroup(
              tPermissionGroupEntity,
            );

            expect(result, isA<FailureState<bool>>());
            verify(() => mockInternetClient.isConnected).called(1);
            verifyNever(
              () => mockLocalDataSource.savePermissionGroup(
                tPermissionGroupModel,
              ),
            );
            verifyNever(
              () => mockRemoteDataSource.createPermissionGroup(any()),
            );
          },
        );

        test(
          'should create group remotely, save locally, and return true when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.createPermissionGroup(any()),
            ).thenAnswer(
              (_) async => SuccessState(data: tPermissionGroupModel),
            );
            when(
              () => mockLocalDataSource.savePermissionGroup(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.createPermissionGroup(
              tPermissionGroupEntity,
            );

            expect(result, isA<SuccessState<bool>>());
            expect(result.data, isTrue);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.createPermissionGroup(any()),
            ).called(1);
            verify(
              () => mockLocalDataSource.savePermissionGroup(
                tPermissionGroupModel,
              ),
            ).called(1);
          },
        );
      });

      group('updatePermissionGroup', () {
        test(
          'should not save group locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.savePermissionGroup(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.updatePermissionGroup(
              tPermissionGroupEntity,
            );

            expect(result, isA<FailureState<bool>>());
            verify(() => mockInternetClient.isConnected).called(1);
            verifyNever(
              () => mockLocalDataSource.savePermissionGroup(
                tPermissionGroupModel,
              ),
            );
            verifyNever(
              () => mockRemoteDataSource.updatePermissionGroup(any()),
            );
          },
        );

        test(
          'should update group remotely, save locally, and return true when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.updatePermissionGroup(any()),
            ).thenAnswer(
              (_) async => SuccessState(data: tPermissionGroupModel),
            );
            when(
              () => mockLocalDataSource.savePermissionGroup(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.updatePermissionGroup(
              tPermissionGroupEntity,
            );

            expect(result, isA<SuccessState<bool>>());
            expect(result.data, isTrue);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.updatePermissionGroup(any()),
            ).called(1);
            verify(
              () => mockLocalDataSource.savePermissionGroup(
                tPermissionGroupModel,
              ),
            ).called(1);
          },
        );
      });

      group('deletePermissionGroup', () {
        test(
          'should not delete group locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.deletePermissionGroup(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.deletePermissionGroup(tId);

            expect(result, isA<FailureState<bool>>());
            verify(() => mockInternetClient.isConnected).called(1);
            verifyNever(() => mockLocalDataSource.deletePermissionGroup(tId));
            verifyNever(
              () => mockRemoteDataSource.deletePermissionGroup(any()),
            );
          },
        );

        test(
          'should delete group remotely, delete locally, and return true when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.deletePermissionGroup(any()),
            ).thenAnswer((_) async => SuccessState.nil);
            when(
              () => mockLocalDataSource.deletePermissionGroup(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.deletePermissionGroup(tId);

            expect(result, isA<SuccessState<bool>>());
            expect(result.data, isTrue);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(
              () => mockRemoteDataSource.deletePermissionGroup(tId),
            ).called(1);
            verify(
              () => mockLocalDataSource.deletePermissionGroup(tId),
            ).called(1);
          },
        );
      });
    });
  });
}
