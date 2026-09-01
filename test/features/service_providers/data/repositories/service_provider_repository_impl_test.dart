import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_company_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_invitation_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/models/responses/service_provider_profile_model.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/repositories/service_provider_repository_impl.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_company_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_invitation_entity.dart';
import 'package:o_jogo_da_obra/features/service_providers/domain/entities/service_provider_profile_entity.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  late MockInternetClient mockInternet;
  late MockServiceProviderRemoteDataSource mockRemoteDataSource;
  late MockServiceProviderLocalDataSource mockLocalDataSource;
  late ServiceProviderRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(EntityFactory.makeServiceProviderCompanyEntity());
    registerFallbackValue(
      ServiceProviderCompanyModel.fromEntity(
        EntityFactory.makeServiceProviderCompanyEntity(),
      ),
    );
    registerFallbackValue(EntityFactory.makeServiceProviderProfileEntity());
    registerFallbackValue(
      ServiceProviderProfileModel.fromEntity(
        EntityFactory.makeServiceProviderProfileEntity(),
      ),
    );
    registerFallbackValue(EntityFactory.makeServiceProviderInvitationEntity());
    registerFallbackValue(
      ServiceProviderInvitationModel.fromEntity(
        EntityFactory.makeServiceProviderInvitationEntity(),
      ),
    );
  });

  setUp(() {
    mockInternet = MockInternetClient();
    mockRemoteDataSource = MockServiceProviderRemoteDataSource();
    mockLocalDataSource = MockServiceProviderLocalDataSource();

    when(() => mockInternet.isConnected).thenReturn(true);
    when(
      () => mockLocalDataSource.saveServiceProviderCompany(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLocalDataSource.saveServiceProviderCompanies(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLocalDataSource.saveServiceProviderProfile(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLocalDataSource.saveServiceProviderProfiles(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLocalDataSource.saveServiceProviderInvitations(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLocalDataSource.deleteServiceProviderInvitation(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLocalDataSource.deleteServiceProviderCompany(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));
    when(
      () => mockLocalDataSource.deleteServiceProviderProfile(any()),
    ).thenAnswer((_) async => const SuccessState(data: true));

    repository = ServiceProviderRepositoryImpl(
      internet: mockInternet,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
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
      'should return SuccessState with domain list and save to local when online call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderCompanies(any()),
        ).thenAnswer((_) async => SuccessState(data: [tCompanyModel]));

        final result = await repository.getServiceProviderCompanies(
          tCompanyEntity.companyId,
        );

        expect(result, isA<SuccessState<List<ServiceProviderCompanyEntity>>>());
        expect(
          (result as SuccessState<List<ServiceProviderCompanyEntity>>)
              .data!
              .first,
          tCompanyEntity,
        );
        verify(
          () => mockRemoteDataSource.getServiceProviderCompanies(
            tCompanyEntity.companyId,
          ),
        ).called(1);
        verify(
          () =>
              mockLocalDataSource.saveServiceProviderCompanies([tCompanyModel]),
        ).called(1);
      },
    );

    test('should fetch from local fallback when offline', () async {
      when(() => mockInternet.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getServiceProviderCompanies(any()),
      ).thenAnswer((_) async => SuccessState(data: [tCompanyModel]));

      final result = await repository.getServiceProviderCompanies(
        tCompanyEntity.companyId,
      );

      expect(result, isA<SuccessState<List<ServiceProviderCompanyEntity>>>());
      expect(
        (result as SuccessState<List<ServiceProviderCompanyEntity>>)
            .data!
            .first,
        tCompanyEntity,
      );
      verifyZeroInteractions(mockRemoteDataSource);
      verify(
        () => mockLocalDataSource.getServiceProviderCompanies(
          tCompanyEntity.companyId,
        ),
      ).called(1);
    });
  });

  group('getServiceProviderCompanyById', () {
    test(
      'should return SuccessState with domain entity and save local when online call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderCompanyById(any()),
        ).thenAnswer((_) async => SuccessState(data: tCompanyModel));

        final result = await repository.getServiceProviderCompanyById(
          tCompanyEntity.id,
        );

        expect(result, isA<SuccessState<ServiceProviderCompanyEntity>>());
        expect(
          (result as SuccessState<ServiceProviderCompanyEntity>).data,
          tCompanyEntity,
        );
        verify(
          () => mockLocalDataSource.saveServiceProviderCompany(tCompanyModel),
        ).called(1);
      },
    );

    test('should fetch from local fallback when offline', () async {
      when(() => mockInternet.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getServiceProviderCompanyById(any()),
      ).thenAnswer((_) async => SuccessState(data: tCompanyModel));

      final result = await repository.getServiceProviderCompanyById(
        tCompanyEntity.id,
      );

      expect(result, isA<SuccessState<ServiceProviderCompanyEntity>>());
      expect(
        (result as SuccessState<ServiceProviderCompanyEntity>).data,
        tCompanyEntity,
      );
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });

  group('createServiceProviderCompany', () {
    test(
      'should return true and save to local when creation succeeds',
      () async {
        when(
          () => mockRemoteDataSource.createServiceProviderCompany(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createServiceProviderCompany(
          tCompanyEntity,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () =>
              mockRemoteDataSource.createServiceProviderCompany(tCompanyModel),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveServiceProviderCompany(tCompanyModel),
        ).called(1);
      },
    );

    test('should save to local when offline', () async {
      when(() => mockInternet.isConnected).thenReturn(false);

      final result = await repository.createServiceProviderCompany(
        tCompanyEntity,
      );

      expect(result, const SuccessState(data: true));
      verifyZeroInteractions(mockRemoteDataSource);
      verify(
        () => mockLocalDataSource.saveServiceProviderCompany(tCompanyModel),
      ).called(1);
    });
  });

  group('updateServiceProviderCompany', () {
    test('should return true and save to local when update succeeds', () async {
      when(
        () => mockRemoteDataSource.updateServiceProviderCompany(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.updateServiceProviderCompany(
        tCompanyEntity,
      );

      expect(result, const SuccessState(data: true));
      verify(
        () => mockRemoteDataSource.updateServiceProviderCompany(tCompanyModel),
      ).called(1);
      verify(
        () => mockLocalDataSource.saveServiceProviderCompany(tCompanyModel),
      ).called(1);
    });
  });

  group('getServiceProviderProfiles', () {
    test(
      'should return SuccessState with domain profiles list when remote call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderProfiles(any()),
        ).thenAnswer((_) async => SuccessState(data: [tProfileModel]));

        final result = await repository.getServiceProviderProfiles(
          tProfileEntity.serviceProviderCompanyId,
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileEntity>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileEntity>>)
              .data!
              .first,
          tProfileEntity,
        );
        verify(
          () =>
              mockLocalDataSource.saveServiceProviderProfiles([tProfileModel]),
        ).called(1);
      },
    );

    test('should fetch profiles from local fallback when offline', () async {
      when(() => mockInternet.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getServiceProviderProfiles(any()),
      ).thenAnswer((_) async => SuccessState(data: [tProfileModel]));

      final result = await repository.getServiceProviderProfiles(
        tProfileEntity.serviceProviderCompanyId,
      );

      expect(result, isA<SuccessState<List<ServiceProviderProfileEntity>>>());
      expect(
        (result as SuccessState<List<ServiceProviderProfileEntity>>)
            .data!
            .first,
        tProfileEntity,
      );
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });

  group('getServiceProviderProfilesByCompanyIds', () {
    test(
      'should return SuccessState with domain profiles list when online call succeeds',
      () async {
        final tCompanyIds = ['comp-1', 'comp-2'];
        when(
          () => mockRemoteDataSource.getServiceProviderProfilesByCompanyIds(
            any(),
          ),
        ).thenAnswer((_) async => SuccessState(data: [tProfileModel]));

        final result = await repository.getServiceProviderProfilesByCompanyIds(
          tCompanyIds,
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileEntity>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileEntity>>)
              .data!
              .first,
          tProfileEntity,
        );
        verify(
          () => mockRemoteDataSource.getServiceProviderProfilesByCompanyIds(
            tCompanyIds,
          ),
        ).called(1);
        verifyNever(() => mockLocalDataSource.saveServiceProviderProfiles(any()));
      },
    );

    test('should return FailureState without local fallback when offline', () async {
      final tCompanyIds = ['comp-1', 'comp-2'];
      when(() => mockInternet.isConnected).thenReturn(false);

      final result = await repository.getServiceProviderProfilesByCompanyIds(
        tCompanyIds,
      );

      expect(result, isA<FailureState<List<ServiceProviderProfileEntity>>>());
      verifyZeroInteractions(mockRemoteDataSource);
      verifyNever(
        () => mockLocalDataSource.getServiceProviderProfilesByCompanyIds(any()),
      );
    });
  });

  group('getServiceProviderProfilesByAuthUser', () {
    test(
      'should return SuccessState with domain profiles list when remote call succeeds',
      () async {
        when(
          () =>
              mockRemoteDataSource.getServiceProviderProfilesByAuthUser(any()),
        ).thenAnswer((_) async => SuccessState(data: [tProfileModel]));

        final result = await repository.getServiceProviderProfilesByAuthUser(
          tProfileEntity.authUserId!,
        );

        expect(result, isA<SuccessState<List<ServiceProviderProfileEntity>>>());
        expect(
          (result as SuccessState<List<ServiceProviderProfileEntity>>)
              .data!
              .first,
          tProfileEntity,
        );
      },
    );
  });

  group('createServiceProviderProfile', () {
    test(
      'should return true and save to local when creation succeeds',
      () async {
        when(
          () => mockRemoteDataSource.createServiceProviderProfile(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createServiceProviderProfile(
          tProfileEntity,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockLocalDataSource.saveServiceProviderProfile(tProfileModel),
        ).called(1);
      },
    );
  });

  group('updateServiceProviderProfile', () {
    test('should return true and save to local when update succeeds', () async {
      when(
        () => mockRemoteDataSource.updateServiceProviderProfile(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.updateServiceProviderProfile(
        tProfileEntity,
      );

      expect(result, const SuccessState(data: true));
      verify(
        () => mockLocalDataSource.saveServiceProviderProfile(tProfileModel),
      ).called(1);
    });
  });

  group('getServiceProviderInvitations', () {
    test(
      'should return SuccessState with domain invitations list when remote call succeeds',
      () async {
        when(
          () => mockRemoteDataSource.getServiceProviderInvitations(any()),
        ).thenAnswer((_) async => SuccessState(data: [tInvitationModel]));

        final result = await repository.getServiceProviderInvitations(
          tInvitationEntity.serviceProviderCompanyId,
        );

        expect(
          result,
          isA<SuccessState<List<ServiceProviderInvitationEntity>>>(),
        );
        expect(
          (result as SuccessState<List<ServiceProviderInvitationEntity>>)
              .data!
              .first,
          tInvitationEntity,
        );
        verify(
          () => mockLocalDataSource.saveServiceProviderInvitations([
            tInvitationModel,
          ]),
        ).called(1);
      },
    );

    test('should fetch invitations from local fallback when offline', () async {
      when(() => mockInternet.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getServiceProviderInvitations(any()),
      ).thenAnswer((_) async => SuccessState(data: [tInvitationModel]));

      final result = await repository.getServiceProviderInvitations(
        tInvitationEntity.serviceProviderCompanyId,
      );

      expect(
        result,
        isA<SuccessState<List<ServiceProviderInvitationEntity>>>(),
      );
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });

  group('sendServiceProviderInvitation', () {
    test('should return true when remote call succeeds', () async {
      when(
        () => mockRemoteDataSource.sendServiceProviderInvitation(
          serviceProviderCompanyId: any(named: 'serviceProviderCompanyId'),
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.sendServiceProviderInvitation(
        serviceProviderCompanyId: tInvitationEntity.serviceProviderCompanyId,
        email: tInvitationEntity.email,
      );

      expect(result, const SuccessState(data: true));
      verify(
        () => mockRemoteDataSource.sendServiceProviderInvitation(
          serviceProviderCompanyId: tInvitationEntity.serviceProviderCompanyId,
          email: tInvitationEntity.email,
        ),
      ).called(1);
    });
  });

  group('deleteServiceProviderInvitation', () {
    test(
      'should return true and delete from local when remote succeeds',
      () async {
        when(
          () => mockRemoteDataSource.deleteServiceProviderInvitation(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteServiceProviderInvitation(
          tInvitationEntity.id,
        );

        expect(result, const SuccessState(data: true));
        verify(
          () => mockLocalDataSource.deleteServiceProviderInvitation(
            tInvitationEntity.id,
          ),
        ).called(1);
      },
    );
  });

  group('acceptServiceProviderInvitation', () {
    test('should return true when remote call succeeds', () async {
      when(
        () => mockRemoteDataSource.acceptServiceProviderInvitation(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.acceptServiceProviderInvitation(
        tInvitationEntity.email,
      );

      expect(result, const SuccessState(data: true));
      verify(
        () => mockRemoteDataSource.acceptServiceProviderInvitation(
          tInvitationEntity.email,
        ),
      ).called(1);
    });
  });

  group('Realtime', () {
    test(
      'watchServiceProviderCompaniesRealtime caches insert/update in local and emits event',
      () async {
        final event = RealtimeEvent<ServiceProviderCompanyModel>(
          eventType: RealtimeEventType.insert,
          id: tCompanyModel.id,
          companyId: tCompanyModel.companyId,
          entity: tCompanyModel,
        );

        when(
          () => mockRemoteDataSource.watchServiceProviderCompaniesRealtime(
            companyId: any(named: 'companyId'),
          ),
        ).thenAnswer((_) => Stream.value(event));

        final stream = repository.watchServiceProviderCompaniesRealtime(
          companyId: tCompanyModel.companyId,
        );

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<ServiceProviderCompanyEntity>>((e) {
              return e.eventType == RealtimeEventType.insert &&
                  e.id == tCompanyModel.id &&
                  e.entity?.name == tCompanyModel.name;
            }),
          ),
        );

        await pumpEventQueue();
        verify(
          () => mockLocalDataSource.saveServiceProviderCompany(tCompanyModel),
        ).called(1);
      },
    );

    test(
      'watchServiceProviderCompaniesRealtime deletes from local and emits event on delete',
      () async {
        final event = RealtimeEvent<ServiceProviderCompanyModel>(
          eventType: RealtimeEventType.delete,
          id: tCompanyModel.id,
          companyId: tCompanyModel.companyId,
        );

        when(
          () => mockRemoteDataSource.watchServiceProviderCompaniesRealtime(
            companyId: any(named: 'companyId'),
          ),
        ).thenAnswer((_) => Stream.value(event));

        final stream = repository.watchServiceProviderCompaniesRealtime(
          companyId: tCompanyModel.companyId,
        );

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<ServiceProviderCompanyEntity>>((e) {
              return e.eventType == RealtimeEventType.delete &&
                  e.id == tCompanyModel.id &&
                  e.entity == null;
            }),
          ),
        );

        await pumpEventQueue();
        verify(
          () => mockLocalDataSource.deleteServiceProviderCompany(
            tCompanyModel.id,
          ),
        ).called(1);
      },
    );

    test(
      'watchServiceProviderCompaniesRealtime deletes from local when entity has deletedAt on update event',
      () async {
        final deletedModel = ServiceProviderCompanyModel.fromEntity(
          tCompanyModel.copyWith(deletedAt: DateTime.now()),
        );
        final event = RealtimeEvent<ServiceProviderCompanyModel>(
          eventType: RealtimeEventType.update,
          id: deletedModel.id,
          companyId: deletedModel.companyId,
          entity: deletedModel,
        );

        when(
          () => mockRemoteDataSource.watchServiceProviderCompaniesRealtime(
            companyId: any(named: 'companyId'),
          ),
        ).thenAnswer((_) => Stream.value(event));

        final stream = repository.watchServiceProviderCompaniesRealtime(
          companyId: deletedModel.companyId,
        );

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<ServiceProviderCompanyEntity>>((e) {
              return e.eventType == RealtimeEventType.update &&
                  e.id == deletedModel.id &&
                  e.entity?.deletedAt != null;
            }),
          ),
        );

        await pumpEventQueue();
        verify(
          () => mockLocalDataSource.deleteServiceProviderCompany(
            deletedModel.id,
          ),
        ).called(1);
      },
    );

    test(
      'watchServiceProviderProfilesRealtime caches insert/update in local and emits event',
      () async {
        final event = RealtimeEvent<ServiceProviderProfileModel>(
          eventType: RealtimeEventType.insert,
          id: tProfileModel.id,
          companyId: tProfileModel.serviceProviderCompanyId,
          entity: tProfileModel,
        );

        when(
          () => mockRemoteDataSource.watchServiceProviderProfilesRealtime(
            serviceProviderCompanyId: any(named: 'serviceProviderCompanyId'),
          ),
        ).thenAnswer((_) => Stream.value(event));

        final stream = repository.watchServiceProviderProfilesRealtime(
          serviceProviderCompanyId: tProfileModel.serviceProviderCompanyId,
        );

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<ServiceProviderProfileEntity>>((e) {
              return e.eventType == RealtimeEventType.insert &&
                  e.id == tProfileModel.id &&
                  e.entity?.name == tProfileModel.name;
            }),
          ),
        );

        await pumpEventQueue();
        verify(
          () => mockLocalDataSource.saveServiceProviderProfile(tProfileModel),
        ).called(1);
      },
    );

    test(
      'watchServiceProviderProfilesRealtime deletes from local and emits event on delete',
      () async {
        final event = RealtimeEvent<ServiceProviderProfileModel>(
          eventType: RealtimeEventType.delete,
          id: tProfileModel.id,
          companyId: tProfileModel.serviceProviderCompanyId,
        );

        when(
          () => mockRemoteDataSource.watchServiceProviderProfilesRealtime(
            serviceProviderCompanyId: any(named: 'serviceProviderCompanyId'),
          ),
        ).thenAnswer((_) => Stream.value(event));

        final stream = repository.watchServiceProviderProfilesRealtime(
          serviceProviderCompanyId: tProfileModel.serviceProviderCompanyId,
        );

        expect(
          stream,
          emits(
            predicate<RealtimeEvent<ServiceProviderProfileEntity>>((e) {
              return e.eventType == RealtimeEventType.delete &&
                  e.id == tProfileModel.id &&
                  e.entity == null;
            }),
          ),
        );

        await pumpEventQueue();
        verify(
          () => mockLocalDataSource.deleteServiceProviderProfile(
            tProfileModel.id,
          ),
        ).called(1);
      },
    );
  });
}
