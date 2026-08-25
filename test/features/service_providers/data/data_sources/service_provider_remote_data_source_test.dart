import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_invitation_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockSupabaseDatabaseClient mockDatabase;
  late MockSupabaseRealtimeClient mockRealtimeClient;
  late ServiceProviderRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<SupabaseFilter>[]);
    for (final value in HttpMethod.values) {
      registerFallbackValue(value);
    }
  });

  setUp(() {
    mockDatabase = MockSupabaseDatabaseClient();
    mockRealtimeClient = MockSupabaseRealtimeClient();
    dataSource = ServiceProviderRemoteDataSourceImpl(
      database: mockDatabase,
      realtimeClient: mockRealtimeClient,
    );
  });

  final tCompanyEntity = EntityFactory.makeServiceProviderCompanyEntity();
  final tCompanyModel = ServiceProviderCompanyModel.fromEntity(tCompanyEntity);

  final tProfileEntity = EntityFactory.makeServiceProviderProfileEntity();
  final tProfileModel = ServiceProviderProfileModel.fromEntity(tProfileEntity);

  final tInvitationEntity = EntityFactory.makeServiceProviderInvitationEntity();
  final tInvitationModel = ServiceProviderInvitationModel.fromEntity(
    tInvitationEntity,
  );

  group('getServiceProviderCompanies', () {
    test(
      'should return SuccessState with list of company models when call to DB is successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tCompanyModel.toJson()]);

        final result = await dataSource.getServiceProviderCompanies(
          tCompanyEntity.companyId,
        );

        expect(result, isA<SuccessState<List<ServiceProviderCompanyModel>>>());
        expect(
          (result as SuccessState<List<ServiceProviderCompanyModel>>)
              .data!
              .first
              .id,
          tCompanyEntity.id,
        );
        verify(
          () => mockDatabase.selectList(
            table: 'service_provider_companies',
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test(
      'should return FailureState when DB call throws an exception',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('DB error'));

        final result = await dataSource.getServiceProviderCompanies(
          tCompanyEntity.companyId,
        );

        expect(result, isA<FailureState<dynamic>>());
      },
    );
  });

  group('getServiceProviderCompanyById', () {
    test(
      'should return SuccessState with company model when company exists',
      () async {
        when(
          () => mockDatabase.selectOne(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => tCompanyModel.toJson());

        final result = await dataSource.getServiceProviderCompanyById(
          tCompanyEntity.id,
        );

        expect(result, isA<SuccessState<ServiceProviderCompanyModel>>());
        expect(
          (result as SuccessState<ServiceProviderCompanyModel>).data!.id,
          tCompanyEntity.id,
        );
      },
    );

    test('should return FailureState when company does not exist', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenAnswer((_) async => null);

      final result = await dataSource.getServiceProviderCompanyById(
        tCompanyEntity.id,
      );

      expect(result, isA<FailureState<dynamic>>());
    });

    test('should return FailureState when DB call fails', () async {
      when(
        () => mockDatabase.selectOne(
          table: any(named: 'table'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('DB error'));

      final result = await dataSource.getServiceProviderCompanyById(
        tCompanyEntity.id,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('createServiceProviderCompany', () {
    test(
      'should return SuccessState(true) when insert is successful',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tCompanyModel.toJson()]);

        final result = await dataSource.createServiceProviderCompany(
          tCompanyModel,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.insert(
            table: 'service_provider_companies',
            values: any(named: 'values'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when insert fails', () async {
      when(
        () => mockDatabase.insert(
          table: any(named: 'table'),
          values: any(named: 'values'),
        ),
      ).thenThrow(Exception('Insert error'));

      final result = await dataSource.createServiceProviderCompany(
        tCompanyModel,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('updateServiceProviderCompany', () {
    test(
      'should return SuccessState(true) when update is successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tCompanyModel.toJson()]);

        final result = await dataSource.updateServiceProviderCompany(
          tCompanyModel,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.update(
            table: 'service_provider_companies',
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test('should return FailureState when update fails', () async {
      when(
        () => mockDatabase.update(
          table: any(named: 'table'),
          values: any(named: 'values'),
          filters: any(named: 'filters'),
        ),
      ).thenThrow(Exception('Update error'));

      final result = await dataSource.updateServiceProviderCompany(
        tCompanyModel,
      );

      expect(result, isA<FailureState<dynamic>>());
    });
  });

  group('getServiceProviderProfiles', () {
    test(
      'should return SuccessState with list of profile models when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.getServiceProviderProfiles(
          tProfileEntity.serviceProviderCompanyId,
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileModel>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileModel>>)
              .data!
              .first
              .id,
          tProfileEntity.id,
        );
      },
    );
  });

  group('getServiceProviderProfilesByCompanyIds', () {
    test(
      'should return SuccessState with list of profile models when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.getServiceProviderProfilesByCompanyIds([
          tProfileEntity.serviceProviderCompanyId,
        ]);

        expect(result, isA<SuccessState<List<ServiceProviderProfileModel>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileModel>>)
              .data!
              .first
              .id,
          tProfileEntity.id,
        );
        verify(
          () => mockDatabase.selectList(
            table: 'service_provider_profiles',
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test(
      'should return empty list when passed empty company ids list',
      () async {
        final result = await dataSource.getServiceProviderProfilesByCompanyIds(
          [],
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileModel>>>());
        expect((result as SuccessState).data, isEmpty);
        verifyZeroInteractions(mockDatabase);
      },
    );
  });

  group('getServiceProviderProfilesByAuthUser', () {
    test(
      'should return SuccessState with list of profile models when successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.getServiceProviderProfilesByAuthUser(
          tProfileEntity.authUserId!,
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileModel>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileModel>>)
              .data!
              .first
              .id,
          tProfileEntity.id,
        );
      },
    );
  });

  group('createServiceProviderProfile', () {
    test(
      'should return SuccessState(true) when insert is successful',
      () async {
        when(
          () => mockDatabase.insert(
            table: any(named: 'table'),
            values: any(named: 'values'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.createServiceProviderProfile(
          tProfileModel,
        );

        expect(result, const SuccessState(data: true));
      },
    );
  });

  group('updateServiceProviderProfile', () {
    test(
      'should return SuccessState(true) when update is successful',
      () async {
        when(
          () => mockDatabase.update(
            table: any(named: 'table'),
            values: any(named: 'values'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tProfileModel.toJson()]);

        final result = await dataSource.updateServiceProviderProfile(
          tProfileModel,
        );

        expect(result, const SuccessState(data: true));
      },
    );
  });

  group('getServiceProviderInvitations', () {
    test(
      'should return SuccessState with list of invitation models when call to DB is successful',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenAnswer((_) async => [tInvitationModel.toJson()]);

        final result = await dataSource.getServiceProviderInvitations(
          tInvitationEntity.serviceProviderCompanyId,
        );

        expect(
          result,
          isA<SuccessState<List<ServiceProviderInvitationModel>>>(),
        );
        expect(
          (result as SuccessState<List<ServiceProviderInvitationModel>>)
              .data!
              .first
              .id,
          tInvitationEntity.id,
        );
        verify(
          () => mockDatabase.selectList(
            table: 'service_provider_invitations',
            filters: any(named: 'filters'),
          ),
        ).called(1);
      },
    );

    test(
      'should return FailureState when DB call throws an exception',
      () async {
        when(
          () => mockDatabase.selectList(
            table: any(named: 'table'),
            filters: any(named: 'filters'),
          ),
        ).thenThrow(Exception('DB error'));

        final result = await dataSource.getServiceProviderInvitations(
          tInvitationEntity.serviceProviderCompanyId,
        );

        expect(result, isA<FailureState<dynamic>>());
      },
    );
  });

  group('sendServiceProviderInvitation', () {
    test(
      'should return SuccessState(true) when invokeFunction call is successful',
      () async {
        when(
          () => mockDatabase.invokeFunction(
            any(),
            method: any(named: 'method'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => const FunctionResponse(status: 200));

        final result = await dataSource.sendServiceProviderInvitation(
          serviceProviderCompanyId: tInvitationEntity.serviceProviderCompanyId,
          email: tInvitationEntity.email,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.invokeFunction(
            'invite-service-provider',
            method: HttpMethod.post,
            body: {
              'service_provider_company_id':
                  tInvitationEntity.serviceProviderCompanyId,
              'email': tInvitationEntity.email,
            },
          ),
        ).called(1);
      },
    );

    test('should return FailureState when invokeFunction throws', () async {
      when(
        () => mockDatabase.invokeFunction(
          any(),
          method: any(named: 'method'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('Já existe um convite pendente para este e-mail.'));

      final result = await dataSource.sendServiceProviderInvitation(
        serviceProviderCompanyId: tInvitationEntity.serviceProviderCompanyId,
        email: tInvitationEntity.email,
      );

      expect(result, isA<FailureState<bool>>());
    });
  });

  group('deleteServiceProviderInvitation', () {
    test(
      'should return SuccessState(true) when rpc call is successful',
      () async {
        when(
          () => mockDatabase.rpc(
            functionName: any(named: 'functionName'),
            params: any(named: 'params'),
            get: any(named: 'get'),
          ),
        ).thenAnswer((_) async => true);

        final result = await dataSource.deleteServiceProviderInvitation(
          tInvitationEntity.id,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.rpc(
            functionName: 'delete_service_provider_invitation',
            params: {'p_invitation_id': tInvitationEntity.id},
          ),
        ).called(1);
      },
    );
  });

  group('acceptServiceProviderInvitation', () {
    test(
      'should return SuccessState(true) when rpc call is successful',
      () async {
        when(
          () => mockDatabase.rpc(
            functionName: any(named: 'functionName'),
            params: any(named: 'params'),
            get: any(named: 'get'),
          ),
        ).thenAnswer((_) async => true);

        final result = await dataSource.acceptServiceProviderInvitation(
          tInvitationEntity.email,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockDatabase.rpc(
            functionName: 'accept_service_provider_invitation',
            params: {'p_email': tInvitationEntity.email},
          ),
        ).called(1);
      },
    );
  });

  group('watchServiceProviderCompaniesRealtime', () {
    test('maps raw postgres change payload to RealtimeEvent', () {
      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.insert,
        newRecord: tCompanyModel.toJson(),
        oldRecord: const {},
        schema: 'public',
        table: 'service_provider_companies',
        errors: const <dynamic>[],
        commitTimestamp: DateTime.now(),
      );

      when(
        () => mockRealtimeClient.streamTableChanges(
          table: 'service_provider_companies',
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) => Stream.value(payload));

      final stream = dataSource.watchServiceProviderCompaniesRealtime(
        companyId: tCompanyEntity.companyId,
      );

      expect(
        stream,
        emits(
          predicate<RealtimeEvent<ServiceProviderCompanyModel>>((event) {
            return event.eventType == RealtimeEventType.insert &&
                event.id == tCompanyModel.id &&
                event.entity?.name == tCompanyModel.name;
          }),
        ),
      );

      verify(
        () => mockRealtimeClient.streamTableChanges(
          table: 'service_provider_companies',
          filter: any(named: 'filter'),
        ),
      ).called(1);
    });
  });

  group('watchServiceProviderProfilesRealtime', () {
    test('maps raw postgres change payload to RealtimeEvent', () {
      final payload = PostgresChangePayload(
        eventType: PostgresChangeEvent.insert,
        newRecord: tProfileModel.toJson(),
        oldRecord: const {},
        schema: 'public',
        table: 'service_provider_profiles',
        errors: const <dynamic>[],
        commitTimestamp: DateTime.now(),
      );

      when(
        () => mockRealtimeClient.streamTableChanges(
          table: 'service_provider_profiles',
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) => Stream.value(payload));

      final stream = dataSource.watchServiceProviderProfilesRealtime(
        serviceProviderCompanyId: tProfileEntity.serviceProviderCompanyId,
      );

      expect(
        stream,
        emits(
          predicate<RealtimeEvent<ServiceProviderProfileModel>>((event) {
            return event.eventType == RealtimeEventType.insert &&
                event.id == tProfileModel.id &&
                event.entity?.name == tProfileModel.name;
          }),
        ),
      );

      verify(
        () => mockRealtimeClient.streamTableChanges(
          table: 'service_provider_profiles',
          filter: any(named: 'filter'),
        ),
      ).called(1);
    });
  });
}
