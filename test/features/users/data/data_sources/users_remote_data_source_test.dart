import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:clean_architecture/features/users/data/models/responses/permission_group_response_model.dart';
import 'package:clean_architecture/features/users/data/models/responses/user_profile_response_model.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

class MockFunctionResponse extends Mock implements FunctionResponse {}

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late UsersRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(
      UserProfileResponseModel.fromEntity(
        EntityFactory.makeUserProfileEntity(),
      ),
    );
    registerFallbackValue(
      PermissionGroupResponseModel.fromEntity(
        EntityFactory.makePermissionGroupEntity(),
      ),
    );
    registerFallbackValue(HttpMethod.post);
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    dataSource = UsersRemoteDataSourceImpl(database: mockDatabase);
  });

  final tUserProfileEntity = EntityFactory.makeUserProfileEntity();
  final tUserProfileModel = UserProfileResponseModel.fromEntity(
    tUserProfileEntity,
  );

  final tPermissionGroupEntity = EntityFactory.makePermissionGroupEntity();
  final tPermissionGroupModel = PermissionGroupResponseModel.fromEntity(
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
        'should return SuccessState<List<UserProfileResponseModel>> on success',
        () async {
          when(
            () => mockDatabase.selectList(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tUserProfileModel.toJson()]);

          final result = await dataSource.getUserProfiles(tCompanyId);

          expect(result, isA<SuccessState<List<UserProfileResponseModel>>>());
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
      test(
        'should return SuccessState<UserProfileResponseModel> on success',
        () async {
          when(
            () => mockDatabase.selectOne(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => tUserProfileModel.toJson());

          final result = await dataSource.getUserProfileById(tId);

          expect(result, isA<SuccessState<UserProfileResponseModel>>());
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
        },
      );
      test('should throw when returning null', () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => null);

        final result = await dataSource.getUserProfileById(tId);

        expect(result, isA<FailureState<UserProfileResponseModel>>());
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
      test(
        'should return SuccessState<UserProfileResponseModel> on success',
        () async {
          when(
            () => mockDatabase.update(
              table: any(named: 'table'),
              values: any(named: 'values'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tUserProfileModel.toJson()]);

          final result = await dataSource.updateUserProfile(tUserProfileModel);

          expect(result, isA<SuccessState<UserProfileResponseModel>>());
          expect(result.data!.id, tUserProfileModel.id);
          verify(
            () => mockDatabase.update(
              table: 'user_profiles',
              values: tUserProfileModel.toJson(),
              filters: [SupabaseFilter.eq('id', tUserProfileModel.id)],
            ),
          ).called(1);
        },
      );
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

    group('inviteUser', () {
      test('should call invokeFunction with correct parameters on success', () async {
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
            },
          ),
        ).called(1);
      });
    });

    // ============================================
    // Permission Groups
    // ============================================
    group('getPermissionGroups', () {
      test(
        'should return SuccessState<List<PermissionGroupResponseModel>> on success',
        () async {
          when(
            () => mockDatabase.selectList(
              table: any(named: 'table'),
              filters: any(named: 'filters'),
            ),
          ).thenAnswer((_) async => [tPermissionGroupModel.toJson()]);

          final result = await dataSource.getPermissionGroups(tCompanyId);

          expect(
            result,
            isA<SuccessState<List<PermissionGroupResponseModel>>>(),
          );
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
        'should return SuccessState<PermissionGroupResponseModel> on success',
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

          expect(result, isA<SuccessState<PermissionGroupResponseModel>>());
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
        'should return SuccessState<PermissionGroupResponseModel> on success',
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

          expect(result, isA<SuccessState<PermissionGroupResponseModel>>());
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
