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
      PermissionGroupResponseModel.fromEntity(
        EntityFactory.makePermissionGroupEntity(),
      ),
    );
    registerFallbackValue(<UserProfileResponseModel>[]);
    registerFallbackValue(<PermissionGroupResponseModel>[]);
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
  final tPermissionGroupModel = PermissionGroupResponseModel.fromEntity(
    tPermissionGroupEntity,
  );
  final tPermissionGroupList = [
    tPermissionGroupEntity,
    tPermissionGroupEntity,
    tPermissionGroupEntity,
  ];
  final tPermissionGroupModelList = tPermissionGroupList
      .map(PermissionGroupResponseModel.fromEntity)
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
            when(
              () => mockRemoteDataSource.getUserProfiles(any()),
            ).thenAnswer((_) async => SuccessState(data: tUserProfileModelList));
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
            when(
              () => mockLocalDataSource.getUserProfiles(any()),
            ).thenAnswer((_) async => SuccessState(data: tUserProfileModelList));

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
            verify(() => mockRemoteDataSource.getUserProfileById(tId)).called(
              1,
            );
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
          'should save profile locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
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
              () => mockLocalDataSource.saveUserProfile(tUserProfileModel),
            ).called(1);
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
            verify(() => mockRemoteDataSource.updateUserProfile(any())).called(
              1,
            );
            verify(
              () => mockLocalDataSource.saveUserProfile(tUserProfileModel),
            ).called(1);
          },
        );
      });

      group('deleteUserProfile', () {
        test(
          'should delete profile locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.deleteUserProfile(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.deleteUserProfile(tId);

            expect(result, isA<SuccessState<bool>>());
            expect(result.data, isTrue);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(() => mockLocalDataSource.deleteUserProfile(tId)).called(1);
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
          'should save group locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
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
              () => mockLocalDataSource.savePermissionGroup(
                tPermissionGroupModel,
              ),
            ).called(1);
            verifyNever(() => mockRemoteDataSource.createPermissionGroup(any()));
          },
        );

        test(
          'should create group remotely, save locally, and return true when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.createPermissionGroup(any()),
            ).thenAnswer((_) async => SuccessState(data: tPermissionGroupModel));
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
          'should save group locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
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
              () => mockLocalDataSource.savePermissionGroup(
                tPermissionGroupModel,
              ),
            ).called(1);
            verifyNever(() => mockRemoteDataSource.updatePermissionGroup(any()));
          },
        );

        test(
          'should update group remotely, save locally, and return true when online',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(true);
            when(
              () => mockRemoteDataSource.updatePermissionGroup(any()),
            ).thenAnswer((_) async => SuccessState(data: tPermissionGroupModel));
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
          'should delete group locally and return true when offline',
          () async {
            when(() => mockInternetClient.isConnected).thenReturn(false);
            when(
              () => mockLocalDataSource.deletePermissionGroup(any()),
            ).thenAnswer((_) async => const SuccessState(data: true));

            final result = await repository.deletePermissionGroup(tId);

            expect(result, isA<SuccessState<bool>>());
            expect(result.data, isTrue);
            verify(() => mockInternetClient.isConnected).called(1);
            verify(() => mockLocalDataSource.deletePermissionGroup(tId)).called(
              1,
            );
            verifyNever(() => mockRemoteDataSource.deletePermissionGroup(any()));
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
            verify(() => mockLocalDataSource.deletePermissionGroup(tId)).called(
              1,
            );
          },
        );
      });
    });
  });
}
