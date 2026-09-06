import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_invitation_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
import 'package:o_jogo_da_obra/features/users/data/repositories/users_repository_impl.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/permission_group_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/users/domain/entities/user_profile_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

void main() {
  late MockInternetClient mockInternetClient;
  late MockUsersRemoteDataSource mockRemoteDataSource;
  late MockUsersLocalDataSource mockLocalDataSource;
  late UsersRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      UserProfileModel.fromEntity(UserFactory.makeUserProfileEntity()),
    );
    registerFallbackValue(
      PermissionGroupModel.fromEntity(UserFactory.makePermissionGroupEntity()),
    );
    registerFallbackValue(
      UserInvitationModel.fromEntity(UserFactory.makeUserInvitationEntity()),
    );
    registerFallbackValue(<UserProfileModel>[]);
    registerFallbackValue(<PermissionGroupModel>[]);
    registerFallbackValue(<UserInvitationModel>[]);
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

  final tUserProfileEntity = UserFactory.makeUserProfileEntity();
  final tUserProfileModel = UserProfileModel.fromEntity(tUserProfileEntity);
  final tUserProfileList = [
    tUserProfileEntity,
    tUserProfileEntity,
    tUserProfileEntity,
  ];
  final tUserProfileModelList = tUserProfileList
      .map(UserProfileModel.fromEntity)
      .toList();

  final tPermissionGroupEntity = UserFactory.makePermissionGroupEntity();
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
            final tInvitationModel = UserInvitationModel.fromEntity(
              UserFactory.makeUserInvitationEntity(),
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
        final tInvitation = UserFactory.makeUserInvitationEntity();

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

    group('Realtime', () {
      test(
        'watchUserProfilesRealtime caches insert/update in local and emits event',
        () async {
          final event = RealtimeEvent<UserProfileModel>(
            eventType: RealtimeEventType.insert,
            id: tUserProfileModel.id,
            companyId: tUserProfileModel.companyId,
            entity: tUserProfileModel,
          );

          when(
            () => mockRemoteDataSource.watchUserProfilesRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => Stream.value(event));
          when(
            () => mockLocalDataSource.saveUserProfile(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchUserProfilesRealtime(
            companyId: tUserProfileModel.companyId,
          );

          expect(
            stream,
            emits(
              predicate<RealtimeEvent<UserProfileEntity>>((e) {
                return e.eventType == RealtimeEventType.insert &&
                    e.id == tUserProfileModel.id &&
                    e.entity?.name == tUserProfileModel.name;
              }),
            ),
          );

          await pumpEventQueue();
          verify(
            () => mockLocalDataSource.saveUserProfile(tUserProfileModel),
          ).called(1);
        },
      );

      test(
        'watchUserProfilesRealtime deletes from local and emits event on delete',
        () async {
          final event = RealtimeEvent<UserProfileModel>(
            eventType: RealtimeEventType.delete,
            id: tUserProfileModel.id,
            companyId: tUserProfileModel.companyId,
          );

          when(
            () => mockRemoteDataSource.watchUserProfilesRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => Stream.value(event));
          when(
            () => mockLocalDataSource.deleteUserProfile(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchUserProfilesRealtime(
            companyId: tUserProfileModel.companyId,
          );

          expect(
            stream,
            emits(
              predicate<RealtimeEvent<UserProfileEntity>>((e) {
                return e.eventType == RealtimeEventType.delete &&
                    e.id == tUserProfileModel.id &&
                    e.entity == null;
              }),
            ),
          );

          await pumpEventQueue();
          verify(
            () => mockLocalDataSource.deleteUserProfile(tUserProfileModel.id),
          ).called(1);
        },
      );

      test(
        'watchUserProfilesRealtime deletes from local when entity has deletedAt on update event',
        () async {
          final deletedModel = UserProfileModel.fromEntity(
            tUserProfileModel.copyWith(deletedAt: DateTime.now()),
          );
          final event = RealtimeEvent<UserProfileModel>(
            eventType: RealtimeEventType.update,
            id: deletedModel.id,
            companyId: deletedModel.companyId,
            entity: deletedModel,
          );

          when(
            () => mockRemoteDataSource.watchUserProfilesRealtime(
              companyId: any(named: 'companyId'),
            ),
          ).thenAnswer((_) => Stream.value(event));
          when(
            () => mockLocalDataSource.deleteUserProfile(any()),
          ).thenAnswer((_) async => const SuccessState(data: true));

          final stream = repository.watchUserProfilesRealtime(
            companyId: deletedModel.companyId,
          );

          expect(
            stream,
            emits(
              predicate<RealtimeEvent<UserProfileEntity>>((e) {
                return e.eventType == RealtimeEventType.update &&
                    e.id == deletedModel.id &&
                    e.entity?.deletedAt != null;
              }),
            ),
          );

          await pumpEventQueue();
          verify(
            () => mockLocalDataSource.deleteUserProfile(deletedModel.id),
          ).called(1);
        },
      );
    });
  });
}
