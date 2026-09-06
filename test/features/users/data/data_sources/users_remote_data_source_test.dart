import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/permission_group_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_invitation_model.dart';
import 'package:o_jogo_da_obra/features/users/data/models/responses/user_profile_model.dart';
import 'package:o_jogo_da_obra/routing/helper/route_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/factories/user_factory.dart';

class MockFunctionResponse extends Mock implements FunctionResponse {}

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late MockSupabaseRealtimeClient mockRealtimeClient;
  late UsersRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      UserProfileModel.fromEntity(UserFactory.makeUserProfileEntity()),
    );
    registerFallbackValue(
      PermissionGroupModel.fromEntity(UserFactory.makePermissionGroupEntity()),
    );
    registerFallbackValue(HttpMethod.post);
  });

  setUp(() {
    GetIt.I.registerLazySingleton<AppConfig>(() => const TestAppConfig());
    mockDatabase = MockSupabaseDatabaseClient();
    mockRealtimeClient = MockSupabaseRealtimeClient();
    dataSource = UsersRemoteDataSourceImpl(
      database: mockDatabase,
      realtimeClient: mockRealtimeClient,
    );
  });

  tearDown(() => GetIt.I.reset());

  final tUserProfileEntity = UserFactory.makeUserProfileEntity();
  final tUserProfileModel = UserProfileModel.fromEntity(tUserProfileEntity);

  final tPermissionGroupEntity = UserFactory.makePermissionGroupEntity();
  final tPermissionGroupModel = PermissionGroupModel.fromEntity(
    tPermissionGroupEntity,
  );

  final tCompanyId = faker.guid.guid();
  final tId = faker.guid.guid();

  group('UsersRemoteDataSourceImpl', () {
    // ============================================
    // User Profiles
    // ============================================
    group('getUserProfiles', () {
      test(
        'should return SuccessState<List<UserProfileModel>> on success',
        () async {
          when(
            () => mockDatabase.selectList(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tUserProfileModel.toJson()]);

          final result = await dataSource.getUserProfiles(tCompanyId);

          expect(result, isA<SuccessState<List<UserProfileModel>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tUserProfileModel.id);
          verify(
            () => mockDatabase.selectList(
              table: 'user_profiles',
              filters: [
                SupabaseFilter.eq('company_id', tCompanyId),
                SupabaseFilter.isFilter('deleted_at', null),
              ],
            ),
          ).called(1);
        },
      );
    });

    group('getUserProfileById', () {
      test('should return SuccessState<UserProfileModel> on success', () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => tUserProfileModel.toJson());

        final result = await dataSource.getUserProfileById(tId);

        expect(result, isA<SuccessState<UserProfileModel>>());
        expect(result.data!.id, tUserProfileModel.id);
        verify(
          () => mockDatabase.selectOne(
            table: 'user_profiles',
            filters: [
              SupabaseFilter.eq('id', tId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      });
      test('should throw when returning null', () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => null);

        final result = await dataSource.getUserProfileById(tId);

        expect(result, isA<FailureState<UserProfileModel>>());
        verify(
          () => mockDatabase.selectOne(
            table: 'user_profiles',
            filters: [
              SupabaseFilter.eq('id', tId),
              SupabaseFilter.isFilter('deleted_at', null),
            ],
          ),
        ).called(1);
      });
    });

    group('updateUserProfile', () {
      test('should return SuccessState<UserProfileModel> on success', () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tUserProfileModel.toJson()]);

        final result = await dataSource.updateUserProfile(tUserProfileModel);

        expect(result, isA<SuccessState<UserProfileModel>>());
        expect(result.data!.id, tUserProfileModel.id);
        verify(
          () => mockDatabase.update(
            table: 'user_profiles',
            values: tUserProfileModel.toJson(),
            filters: [SupabaseFilter.eq('id', tUserProfileModel.id)],
          ),
        ).called(1);
      });
    });

    group('deleteUserProfile', () {
      test('should return SuccessState<void> on success', () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tUserProfileModel.toJson()]);

        final result = await dataSource.deleteUserProfile(tId);

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockDatabase.update(
            table: 'user_profiles',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tId)],
          ),
        ).called(1);
      });
    });

    group('watchUserProfilesRealtime', () {
      test('streams realtime events for user profiles', () {
        final payload = PostgresChangePayload(
          eventType: PostgresChangeEvent.insert,
          newRecord: tUserProfileModel.toJson(),
          oldRecord: {},
          schema: 'public',
          table: 'user_profiles',
          errors: <dynamic>[],
          commitTimestamp: DateTime.now(),
        );

        when(
          () => mockRealtimeClient.streamTableChanges(
            table: 'user_profiles',
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) => Stream.value(payload));

        final stream = dataSource.watchUserProfilesRealtime(
          companyId: tCompanyId,
        );

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<UserProfileModel>>((event) {
              return event.eventType == RealtimeEventType.insert &&
                  event.id == tUserProfileModel.id &&
                  event.entity?.name == tUserProfileModel.name;
            }),
          ),
        );
      });
    });

    group('inviteUser', () {
      test(
        'should call invokeFunction with correct parameters on success',
        () async {
          final email = faker.internet.email();
          final mockResponse = MockFunctionResponse();
          when(() => mockResponse.status).thenReturn(200);

          when(
            () => mockDatabase.invokeFunction(
              any(),
              method: any(named: 'method'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => mockResponse);

          final result = await dataSource.inviteUser(
            email: email,
            companyId: tCompanyId,
            groupId: tId,
          );

          expect(result, isA<SuccessState<void>>());
          verify(
            () => mockDatabase.invokeFunction(
              'invite-user',
              method: HttpMethod.post,
              body: {
                'email': email,
                'company_id': tCompanyId,
                'permission_group_id': tId,
                'redirect_url':
                    '${TestAppConfig.defaultWebBaseUrl}$kAcceptInvitePath',
              },
            ),
          ).called(1);
        },
      );
    });

    group('getPendingInvitations', () {
      test(
        'should return SuccessState<List<UserInvitationModel>> on success',
        () async {
          final tInvitationModel = UserInvitationModel.fromEntity(
            UserFactory.makeUserInvitationEntity(),
          );

          when(
            () => mockDatabase.rpc(
              functionName: any(named: 'functionName'),
              params: any(named: 'params'),
              get: any(named: 'get'),
            ),
          ).thenAnswer((_) async => [tInvitationModel.toJson()]);

          final result = await dataSource.getPendingInvitations(tCompanyId);

          expect(result, isA<SuccessState<List<UserInvitationModel>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tInvitationModel.id);
          verify(
            () => mockDatabase.rpc(
              functionName: 'get_pending_invitations',
              params: {'target_company_id': tCompanyId},
            ),
          ).called(1);
        },
      );
    });

    group('revokeInvitation', () {
      test('should return SuccessState<void> on success', () async {
        when(
          () => mockDatabase.rpc(
            functionName: any(named: 'functionName'),
            params: any(named: 'params'),
            get: any(named: 'get'),
          ),
        ).thenAnswer((_) async => null);

        final result = await dataSource.revokeInvitation(tId);

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockDatabase.rpc(
            functionName: 'revoke_invitation',
            params: {'invitation_id': tId},
          ),
        ).called(1);
      });
    });

    group('resendInvitation', () {
      test(
        'should call invokeFunction with correct parameters on success',
        () async {
          final tInvitation = UserFactory.makeUserInvitationEntity();
          final mockResponse = MockFunctionResponse();
          when(() => mockResponse.status).thenReturn(200);

          when(
            () => mockDatabase.invokeFunction(
              any(),
              method: any(named: 'method'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => mockResponse);

          final result = await dataSource.resendInvitation(tInvitation);

          expect(result, isA<SuccessState<void>>());
          verify(
            () => mockDatabase.invokeFunction(
              'invite-user',
              method: HttpMethod.post,
              body: {
                'email': tInvitation.email,
                'company_id': tInvitation.companyId,
                'permission_group_id': tInvitation.permissionGroupId,
                'redirect_url':
                    '${TestAppConfig.defaultWebBaseUrl}$kAcceptInvitePath',
              },
            ),
          ).called(1);
        },
      );
    });

    // ============================================
    // Permission Groups
    // ============================================
    group('getPermissionGroups', () {
      test(
        'should return SuccessState<List<PermissionGroupModel>> on success',
        () async {
          when(
            () => mockDatabase.selectList(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tPermissionGroupModel.toJson()]);

          final result = await dataSource.getPermissionGroups(tCompanyId);

          expect(result, isA<SuccessState<List<PermissionGroupModel>>>());
          expect(result.data, hasLength(1));
          expect(result.data!.first.id, tPermissionGroupModel.id);
          verify(
            () => mockDatabase.selectList(
              table: 'permission_groups',
              filters: [
                SupabaseFilter.eq('company_id', tCompanyId),
                SupabaseFilter.isFilter('deleted_at', null),
              ],
            ),
          ).called(1);
        },
      );
    });

    group('createPermissionGroup', () {
      test(
        'should return SuccessState<PermissionGroupModel> on success',
        () async {
          when(
            () => mockDatabase.insert(
              table: any(named: 'table'),
              values: any(named: 'values'),
            ),
          ).thenAnswer((_) async => [tPermissionGroupModel.toJson()]);

          final result = await dataSource.createPermissionGroup(
            tPermissionGroupModel,
          );

          expect(result, isA<SuccessState<PermissionGroupModel>>());
          expect(result.data!.id, tPermissionGroupModel.id);
          verify(
            () => mockDatabase.insert(
              table: 'permission_groups',
              values: tPermissionGroupModel.toJson(),
            ),
          ).called(1);
        },
      );
    });

    group('updatePermissionGroup', () {
      test(
        'should return SuccessState<PermissionGroupModel> on success',
        () async {
          when(
            () => mockDatabase.update(
              table: any(named: 'table'),
              values: any(named: 'values'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tPermissionGroupModel.toJson()]);

          final result = await dataSource.updatePermissionGroup(
            tPermissionGroupModel,
          );

          expect(result, isA<SuccessState<PermissionGroupModel>>());
          expect(result.data!.id, tPermissionGroupModel.id);
          verify(
            () => mockDatabase.update(
              table: 'permission_groups',
              values: tPermissionGroupModel.toJson(),
              filters: [SupabaseFilter.eq('id', tPermissionGroupModel.id)],
            ),
          ).called(1);
        },
      );
    });

    group('deletePermissionGroup', () {
      test('should return SuccessState<void> on success', () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tPermissionGroupModel.toJson()]);

        final result = await dataSource.deletePermissionGroup(tId);

        expect(result, isA<SuccessState<void>>());
        verify(
          () => mockDatabase.update(
            table: 'permission_groups',
            values: any(named: 'values'),
            filters: [SupabaseFilter.eq('id', tId)],
          ),
        ).called(1);
      });
    });
  });
}
