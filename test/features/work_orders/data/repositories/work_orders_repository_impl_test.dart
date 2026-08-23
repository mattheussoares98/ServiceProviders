import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/task_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/requests/work_order_change_request_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_change_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_history_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/repositories/work_orders_repository_impl.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/data_source_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';
import '../../../../../testing/mocks/repository_mocks.dart';

void main() {
  _providerWorkOrdersTests();

  late MockInternetClient mockInternetClient;
  late MockWorkOrdersRemoteDataSource mockRemoteDataSource;
  late MockWorkOrdersLocalDataSource mockLocalDataSource;
  late MockOfflineTracker mockOfflineTracker;
  late MockSessionRepository mockSessionRepository;
  late WorkOrdersRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      WorkOrderModel.fromEntity(EntityFactory.makeWorkOrderEntity()),
    );
    registerFallbackValue(<WorkOrderModel>[
      WorkOrderModel.fromEntity(EntityFactory.makeWorkOrderEntity()),
    ]);
    registerFallbackValue(TaskModel.fromEntity(EntityFactory.makeTaskEntity()));
    registerFallbackValue(
      TaskRequestModel.fromEntity(EntityFactory.makeTaskEntity()),
    );
    registerFallbackValue(
      WorkOrderChangeRequestModel.fromEntity(
        EntityFactory.makeWorkOrderChangeRequestEntity(),
      ),
    );
    registerFallbackValue(
      WorkOrderChangeRequestRequestModel.fromEntity(
        EntityFactory.makeWorkOrderChangeRequestEntity(),
      ),
    );
    registerFallbackValue(
      WorkOrderHistoryModel.fromEntity(
        EntityFactory.makeWorkOrderHistoryEntity(),
      ),
    );
    registerFallbackValue(const WorkOrderFilter());
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockWorkOrdersRemoteDataSource();
    mockLocalDataSource = MockWorkOrdersLocalDataSource();
    mockOfflineTracker = MockOfflineTracker();
    mockSessionRepository = MockSessionRepository();
    when(() => mockOfflineTracker.recordOfflineAction()).thenReturn(false);
    when(() => mockOfflineTracker.reset()).thenReturn(null);
    when(
      () => mockSessionRepository.getSelectedMode(),
    ).thenReturn(AppMode.internal.name);

    repository = WorkOrdersRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      offlineTracker: mockOfflineTracker,
      sessionRepository: mockSessionRepository,
    );
  });

  final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity();
  final tWorkOrderModel = WorkOrderModel.fromEntity(tWorkOrderEntity);

  final tTaskEntity = EntityFactory.makeTaskEntity();
  final tTaskModel = TaskModel.fromEntity(tTaskEntity);

  final tChangeEntity = EntityFactory.makeWorkOrderChangeRequestEntity();
  final tChangeModel = WorkOrderChangeRequestModel.fromEntity(tChangeEntity);

  final tHistoryEntity = EntityFactory.makeWorkOrderHistoryEntity();
  final tHistoryModel = WorkOrderHistoryModel.fromEntity(tHistoryEntity);

  final tCompanyId = faker.guid.guid();
  final tWorkOrderId = faker.guid.guid();
  final tTaskId = faker.guid.guid();
  final tChangeId = faker.guid.guid();
  final tReviewerId = faker.guid.guid();

  group('getWorkOrders', () {
    test(
      'should return remote data and cache it locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getWorkOrders(
            any(),
            filter: any(named: 'filter'),
            pageSize: any(named: 'pageSize'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => SuccessState(data: [tWorkOrderModel]));
        when(
          () => mockLocalDataSource.saveWorkOrders(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getWorkOrders(tCompanyId);

        expect(result, isA<SuccessState<List<WorkOrderEntity>>>());
        expect(result.data, [tWorkOrderEntity]);
        verify(
          () => mockRemoteDataSource.getWorkOrders(
            tCompanyId,
            filter: any(named: 'filter'),
            pageSize: any(named: 'pageSize'),
            offset: any(named: 'offset'),
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveWorkOrders([tWorkOrderModel]),
        ).called(1);
      },
    );

    test('should return local data when internet is disconnected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => SuccessState(data: [tWorkOrderModel]));

      final result = await repository.getWorkOrders(tCompanyId);

      expect(result, isA<SuccessState<List<WorkOrderEntity>>>());
      expect(result.data, [tWorkOrderEntity]);
      verify(
        () => mockLocalDataSource.getWorkOrders(
          tCompanyId,
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
      verifyNever(
        () => mockRemoteDataSource.getWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      );
    });

    test(
      'should return FailureState when remote call fails and internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getWorkOrders(
            any(),
            filter: any(named: 'filter'),
            pageSize: any(named: 'pageSize'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.getWorkOrders(tCompanyId);

        expect(result, isA<FailureState<List<WorkOrderEntity>>>());
        expect(result.message, 'Server error');
        verify(
          () => mockRemoteDataSource.getWorkOrders(
            tCompanyId,
            filter: any(named: 'filter'),
            pageSize: any(named: 'pageSize'),
            offset: any(named: 'offset'),
          ),
        ).called(1);
        verifyNever(
          () => mockLocalDataSource.getWorkOrders(
            any(),
            filter: any(named: 'filter'),
            pageSize: any(named: 'pageSize'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );
  });

  group('getWorkOrderById', () {
    test(
      'should return remote data and cache it locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getWorkOrderById(any()),
        ).thenAnswer((_) async => SuccessState(data: tWorkOrderModel));
        when(
          () => mockLocalDataSource.saveWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getWorkOrderById(tWorkOrderId);

        expect(result, isA<SuccessState<WorkOrderEntity>>());
        expect(result.data, tWorkOrderEntity);
        verify(
          () => mockRemoteDataSource.getWorkOrderById(tWorkOrderId),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveWorkOrder(tWorkOrderModel),
        ).called(1);
      },
    );

    test('should return local data when internet is disconnected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getWorkOrderById(any()),
      ).thenAnswer((_) async => SuccessState(data: tWorkOrderModel));

      final result = await repository.getWorkOrderById(tWorkOrderId);

      expect(result, isA<SuccessState<WorkOrderEntity>>());
      expect(result.data, tWorkOrderEntity);
      verify(
        () => mockLocalDataSource.getWorkOrderById(tWorkOrderId),
      ).called(1);
      verifyNever(() => mockRemoteDataSource.getWorkOrderById(any()));
    });

    test(
      'should return FailureState when remote call fails and internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getWorkOrderById(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.getWorkOrderById(tWorkOrderId);

        expect(result, isA<FailureState<WorkOrderEntity>>());
        expect(result.message, 'Server error');
        verify(
          () => mockRemoteDataSource.getWorkOrderById(tWorkOrderId),
        ).called(1);
        verifyNever(() => mockLocalDataSource.getWorkOrderById(any()));
      },
    );
  });

  group('createWorkOrder', () {
    test(
      'should call remote, save locally, and return SuccessState(true) when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.createWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createWorkOrder(tWorkOrderEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRemoteDataSource.createWorkOrder(any())).called(1);
        verify(
          () => mockLocalDataSource.saveWorkOrder(tWorkOrderModel),
        ).called(1);
      },
    );

    test(
      'should only save locally and return SuccessState(true) when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createWorkOrder(tWorkOrderEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockLocalDataSource.saveWorkOrder(tWorkOrderModel),
        ).called(1);
        verifyNever(() => mockRemoteDataSource.createWorkOrder(any()));
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.createWorkOrder(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.createWorkOrder(tWorkOrderEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(() => mockLocalDataSource.saveWorkOrder(tWorkOrderModel));
      },
    );
  });

  group('updateWorkOrder', () {
    test(
      'should call remote, save locally, and return SuccessState(true) when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.updateWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateWorkOrder(tWorkOrderEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRemoteDataSource.updateWorkOrder(any())).called(1);
        verify(
          () => mockLocalDataSource.saveWorkOrder(tWorkOrderModel),
        ).called(1);
      },
    );

    test(
      'should only save locally and return SuccessState(true) when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateWorkOrder(tWorkOrderEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockLocalDataSource.saveWorkOrder(tWorkOrderModel),
        ).called(1);
        verifyNever(() => mockRemoteDataSource.updateWorkOrder(any()));
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.updateWorkOrder(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.updateWorkOrder(tWorkOrderEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(() => mockLocalDataSource.saveWorkOrder(tWorkOrderModel));
      },
    );
  });

  group('deleteWorkOrder', () {
    test(
      'should call remote, delete locally with hardDeleteWorkOrder, and return SuccessState(true) when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.deleteWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.deleteWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockLocalDataSource.hardDeleteWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteWorkOrder(tWorkOrderId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockRemoteDataSource.deleteWorkOrder(tWorkOrderId),
        ).called(1);
        verify(
          () => mockLocalDataSource.hardDeleteWorkOrder(tWorkOrderId),
        ).called(1);
      },
    );

    test(
      'should only delete locally and return SuccessState(true) when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.deleteWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteWorkOrder(tWorkOrderId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockLocalDataSource.deleteWorkOrder(tWorkOrderId),
        ).called(1);
        verifyNever(() => mockRemoteDataSource.deleteWorkOrder(any()));
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.deleteWorkOrder(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.deleteWorkOrder(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.deleteWorkOrder(tWorkOrderId);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(() => mockLocalDataSource.deleteWorkOrder(tWorkOrderId));
      },
    );
  });

  group('hardDeleteWorkOrder', () {
    test('should delegate to localDataSource.hardDeleteWorkOrder', () async {
      when(
        () => mockLocalDataSource.hardDeleteWorkOrder(any()),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.hardDeleteWorkOrder(tWorkOrderId);

      expect(result, isA<SuccessState<bool>>());
      expect(result.data, true);
      verify(
        () => mockLocalDataSource.hardDeleteWorkOrder(tWorkOrderId),
      ).called(1);
    });
  });

  group('syncWorkOrders', () {
    test('should return FailureState when internet is disconnected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.syncWorkOrders(tCompanyId);

      expect(result, isA<FailureState<bool>>());
    });

    test(
      'initial sync (when lastSyncAt is null) should fetch active work orders and batch save locally',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.getLastUpdatedTimestamp(tCompanyId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemoteDataSource.getWorkOrders(tCompanyId, pageSize: 100),
        ).thenAnswer((_) async => SuccessState(data: [tWorkOrderModel]));
        when(
          () => mockLocalDataSource.saveWorkOrders(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.syncWorkOrders(tCompanyId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockRemoteDataSource.getWorkOrders(tCompanyId, pageSize: 100),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveWorkOrders([tWorkOrderModel]),
        ).called(1);
        verify(
          () => mockLocalDataSource.getLastUpdatedTimestamp(tCompanyId),
        ).called(1);
      },
    );

    test(
      'delta sync (when lastSyncAt is not null) should fetch delta changes and batch save locally',
      () async {
        final tLastSync = DateTime.now().toUtc().subtract(
          const Duration(hours: 2),
        );
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.getLastUpdatedTimestamp(tCompanyId),
        ).thenAnswer((_) async => tLastSync);
        when(
          () => mockRemoteDataSource.getWorkOrdersDelta(
            tCompanyId,
            since: any(named: 'since'),
          ),
        ).thenAnswer((_) async => SuccessState(data: [tWorkOrderModel]));
        when(
          () => mockLocalDataSource.saveWorkOrders(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.syncWorkOrders(tCompanyId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockRemoteDataSource.getWorkOrdersDelta(
            tCompanyId,
            since: tLastSync,
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveWorkOrders([tWorkOrderModel]),
        ).called(1);
      },
    );

    test(
      'should return FailureState when remote fetch fails during sync',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.getLastUpdatedTimestamp(tCompanyId),
        ).thenAnswer((_) async => null);
        when(
          () => mockRemoteDataSource.getWorkOrders(
            any(),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => FailureState(message: 'Remote error'));

        final result = await repository.syncWorkOrders(tCompanyId);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Remote error');
      },
    );
  });

  group('getTasksByWorkOrder', () {
    test(
      'should return remote data and cache it locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getTasksByWorkOrder(any()),
        ).thenAnswer((_) async => SuccessState(data: [tTaskModel]));
        when(
          () => mockLocalDataSource.saveTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getTasksByWorkOrder(tWorkOrderId);

        expect(result, isA<SuccessState<List<TaskEntity>>>());
        expect(result.data, [tTaskEntity]);
        verify(
          () => mockRemoteDataSource.getTasksByWorkOrder(tWorkOrderId),
        ).called(1);
        verify(() => mockLocalDataSource.saveTask(tTaskModel)).called(1);
      },
    );

    test('should return local data when internet is disconnected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getTasksByWorkOrder(any()),
      ).thenAnswer((_) async => SuccessState(data: [tTaskModel]));

      final result = await repository.getTasksByWorkOrder(tWorkOrderId);

      expect(result, isA<SuccessState<List<TaskEntity>>>());
      expect(result.data, [tTaskEntity]);
      verify(
        () => mockLocalDataSource.getTasksByWorkOrder(tWorkOrderId),
      ).called(1);
      verifyNever(() => mockRemoteDataSource.getTasksByWorkOrder(any()));
    });

    test(
      'should return FailureState when remote call fails and internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getTasksByWorkOrder(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.getTasksByWorkOrder(tWorkOrderId);

        expect(result, isA<FailureState<List<TaskEntity>>>());
        expect(result.message, 'Server error');
        verify(
          () => mockRemoteDataSource.getTasksByWorkOrder(tWorkOrderId),
        ).called(1);
        verifyNever(() => mockLocalDataSource.getTasksByWorkOrder(any()));
      },
    );
  });

  group('createTask', () {
    test(
      'should call remote, save locally, and return SuccessState(true) when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.createTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createTask(tTaskEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRemoteDataSource.createTask(any())).called(1);
        verify(() => mockLocalDataSource.saveTask(tTaskModel)).called(1);
      },
    );

    test(
      'should only save locally and return SuccessState(true) when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createTask(tTaskEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockLocalDataSource.saveTask(tTaskModel)).called(1);
        verifyNever(() => mockRemoteDataSource.createTask(any()));
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.createTask(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.createTask(tTaskEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(() => mockLocalDataSource.saveTask(tTaskModel));
      },
    );
  });

  group('updateTask', () {
    test(
      'should call remote, save locally, and return SuccessState(true) when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.updateTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateTask(tTaskEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRemoteDataSource.updateTask(any())).called(1);
        verify(() => mockLocalDataSource.saveTask(tTaskModel)).called(1);
      },
    );

    test(
      'should only save locally and return SuccessState(true) when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.updateTask(tTaskEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockLocalDataSource.saveTask(tTaskModel)).called(1);
        verifyNever(() => mockRemoteDataSource.updateTask(any()));
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.updateTask(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.updateTask(tTaskEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(() => mockLocalDataSource.saveTask(tTaskModel));
      },
    );
  });

  group('deleteTask', () {
    test(
      'should call remote, delete locally, and return SuccessState(true) when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.deleteTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.deleteTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteTask(tTaskId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRemoteDataSource.deleteTask(tTaskId)).called(1);
        verify(() => mockLocalDataSource.deleteTask(tTaskId)).called(1);
      },
    );

    test(
      'should only delete locally and return SuccessState(true) when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.deleteTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.deleteTask(tTaskId);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockLocalDataSource.deleteTask(tTaskId)).called(1);
        verifyNever(() => mockRemoteDataSource.deleteTask(any()));
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.deleteTask(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.deleteTask(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.deleteTask(tTaskId);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(() => mockLocalDataSource.deleteTask(tTaskId));
      },
    );
  });

  group('getChangeRequests', () {
    test(
      'should return remote data and cache it locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getChangeRequests(any()),
        ).thenAnswer((_) async => SuccessState(data: [tChangeModel]));
        when(
          () => mockLocalDataSource.saveChangeRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getChangeRequests(tCompanyId);

        expect(result, isA<SuccessState<List<WorkOrderChangeRequestEntity>>>());
        expect(result.data, [tChangeEntity]);
        verify(
          () => mockRemoteDataSource.getChangeRequests(tCompanyId),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveChangeRequest(tChangeModel),
        ).called(1);
      },
    );

    test('should return local data when internet is disconnected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getChangeRequests(any()),
      ).thenAnswer((_) async => SuccessState(data: [tChangeModel]));

      final result = await repository.getChangeRequests(tCompanyId);

      expect(result, isA<SuccessState<List<WorkOrderChangeRequestEntity>>>());
      expect(result.data, [tChangeEntity]);
      verify(() => mockLocalDataSource.getChangeRequests(tCompanyId)).called(1);
      verifyNever(() => mockRemoteDataSource.getChangeRequests(any()));
    });

    test(
      'should return FailureState when remote call fails and internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getChangeRequests(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.getChangeRequests(tCompanyId);

        expect(result, isA<FailureState<List<WorkOrderChangeRequestEntity>>>());
        expect(result.message, 'Server error');
        verify(
          () => mockRemoteDataSource.getChangeRequests(tCompanyId),
        ).called(1);
        verifyNever(() => mockLocalDataSource.getChangeRequests(any()));
      },
    );
  });

  group('createChangeRequest', () {
    test(
      'should call remote, save locally, and return SuccessState(true) when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveChangeRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.createChangeRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createChangeRequest(tChangeEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(() => mockRemoteDataSource.createChangeRequest(any())).called(1);
        verify(
          () => mockLocalDataSource.saveChangeRequest(tChangeModel),
        ).called(1);
      },
    );

    test(
      'should only save locally and return SuccessState(true) when internet is disconnected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.saveChangeRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.createChangeRequest(tChangeEntity);

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockLocalDataSource.saveChangeRequest(tChangeModel),
        ).called(1);
        verifyNever(() => mockRemoteDataSource.createChangeRequest(any()));
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.saveChangeRequest(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.createChangeRequest(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.createChangeRequest(tChangeEntity);

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(() => mockLocalDataSource.saveChangeRequest(tChangeModel));
      },
    );
  });

  group('reviewChangeRequest', () {
    test(
      'should call remote, save locally, and return SuccessState(true) when internet is connected',
      () async {
        const tStatus = ChangeRequestStatus.approved;
        final tReason = faker.lorem.sentence();

        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.reviewChangeRequest(
            id: any(named: 'id'),
            status: any(named: 'status'),
            rejectionReason: any(named: 'rejectionReason'),
            reviewedById: any(named: 'reviewedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.reviewChangeRequest(
            id: any(named: 'id'),
            status: any(named: 'status'),
            rejectionReason: any(named: 'rejectionReason'),
            reviewedById: any(named: 'reviewedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.reviewChangeRequest(
          id: tChangeId,
          status: tStatus,
          rejectionReason: tReason,
          reviewedById: tReviewerId,
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockRemoteDataSource.reviewChangeRequest(
            id: tChangeId,
            status: tStatus.code,
            rejectionReason: tReason,
            reviewedById: tReviewerId,
          ),
        ).called(1);
        verify(
          () => mockLocalDataSource.reviewChangeRequest(
            id: tChangeId,
            status: tStatus.code,
            rejectionReason: tReason,
            reviewedById: tReviewerId,
          ),
        ).called(1);
      },
    );

    test(
      'should only save locally and return SuccessState(true) when internet is disconnected',
      () async {
        const tStatus = ChangeRequestStatus.approved;
        final tReason = faker.lorem.sentence();

        when(() => mockInternetClient.isConnected).thenReturn(false);
        when(
          () => mockLocalDataSource.reviewChangeRequest(
            id: any(named: 'id'),
            status: any(named: 'status'),
            rejectionReason: any(named: 'rejectionReason'),
            reviewedById: any(named: 'reviewedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.reviewChangeRequest(
          id: tChangeId,
          status: tStatus,
          rejectionReason: tReason,
          reviewedById: tReviewerId,
        );

        expect(result, isA<SuccessState<bool>>());
        expect(result.data, true);
        verify(
          () => mockLocalDataSource.reviewChangeRequest(
            id: tChangeId,
            status: tStatus.code,
            rejectionReason: tReason,
            reviewedById: tReviewerId,
          ),
        ).called(1);
        verifyNever(
          () => mockRemoteDataSource.reviewChangeRequest(
            id: any(named: 'id'),
            status: any(named: 'status'),
            rejectionReason: any(named: 'rejectionReason'),
            reviewedById: any(named: 'reviewedById'),
          ),
        );
      },
    );

    test(
      'should return FailureState when remote call fails on connected internet',
      () async {
        const tStatus = ChangeRequestStatus.approved;
        final tReason = faker.lorem.sentence();

        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockLocalDataSource.reviewChangeRequest(
            id: any(named: 'id'),
            status: any(named: 'status'),
            rejectionReason: any(named: 'rejectionReason'),
            reviewedById: any(named: 'reviewedById'),
          ),
        ).thenAnswer((_) async => const SuccessState(data: true));
        when(
          () => mockRemoteDataSource.reviewChangeRequest(
            id: any(named: 'id'),
            status: any(named: 'status'),
            rejectionReason: any(named: 'rejectionReason'),
            reviewedById: any(named: 'reviewedById'),
          ),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.reviewChangeRequest(
          id: tChangeId,
          status: tStatus,
          rejectionReason: tReason,
          reviewedById: tReviewerId,
        );

        expect(result, isA<FailureState<bool>>());
        expect(result.message, 'Server error');
        verifyNever(
          () => mockLocalDataSource.reviewChangeRequest(
            id: any(named: 'id'),
            status: any(named: 'status'),
            rejectionReason: any(named: 'rejectionReason'),
            reviewedById: any(named: 'reviewedById'),
          ),
        );
      },
    );
  });

  group('getWorkOrderHistory', () {
    test(
      'should return remote data and cache it locally when internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getWorkOrderHistory(any()),
        ).thenAnswer((_) async => SuccessState(data: [tHistoryModel]));
        when(
          () => mockLocalDataSource.saveWorkOrderHistory(any()),
        ).thenAnswer((_) async => const SuccessState(data: true));

        final result = await repository.getWorkOrderHistory(tWorkOrderId);

        expect(result, isA<SuccessState<List<WorkOrderHistoryEntity>>>());
        expect(result.data, [tHistoryEntity]);
        verify(
          () => mockRemoteDataSource.getWorkOrderHistory(tWorkOrderId),
        ).called(1);
        verify(
          () => mockLocalDataSource.saveWorkOrderHistory(tHistoryModel),
        ).called(1);
      },
    );

    test('should return local data when internet is disconnected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);
      when(
        () => mockLocalDataSource.getWorkOrderHistory(any()),
      ).thenAnswer((_) async => SuccessState(data: [tHistoryModel]));

      final result = await repository.getWorkOrderHistory(tWorkOrderId);

      expect(result, isA<SuccessState<List<WorkOrderHistoryEntity>>>());
      expect(result.data, [tHistoryEntity]);
      verify(
        () => mockLocalDataSource.getWorkOrderHistory(tWorkOrderId),
      ).called(1);
      verifyNever(() => mockRemoteDataSource.getWorkOrderHistory(any()));
    });

    test(
      'should return FailureState when remote call fails and internet is connected',
      () async {
        when(() => mockInternetClient.isConnected).thenReturn(true);
        when(
          () => mockRemoteDataSource.getWorkOrderHistory(any()),
        ).thenAnswer((_) async => FailureState(message: 'Server error'));

        final result = await repository.getWorkOrderHistory(tWorkOrderId);

        expect(result, isA<FailureState<List<WorkOrderHistoryEntity>>>());
        expect(result.message, 'Server error');
        verify(
          () => mockRemoteDataSource.getWorkOrderHistory(tWorkOrderId),
        ).called(1);
        verifyNever(() => mockLocalDataSource.getWorkOrderHistory(any()));
      },
    );
  });
}

void _providerWorkOrdersTests() {
  late MockInternetClient mockInternetClient;
  late MockWorkOrdersRemoteDataSource mockRemoteDataSource;
  late MockWorkOrdersLocalDataSource mockLocalDataSource;
  late MockOfflineTracker mockOfflineTracker;
  late MockSessionRepository mockSessionRepository;
  late WorkOrdersRepositoryImpl repository;

  setUp(() {
    mockInternetClient = MockInternetClient();
    mockRemoteDataSource = MockWorkOrdersRemoteDataSource();
    mockLocalDataSource = MockWorkOrdersLocalDataSource();
    mockOfflineTracker = MockOfflineTracker();
    mockSessionRepository = MockSessionRepository();
    when(() => mockOfflineTracker.recordOfflineAction()).thenReturn(false);
    when(() => mockOfflineTracker.reset()).thenReturn(null);
    when(
      () => mockSessionRepository.getSelectedMode(),
    ).thenReturn(AppMode.provider.name);

    repository = WorkOrdersRepositoryImpl(
      internet: mockInternetClient,
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      offlineTracker: mockOfflineTracker,
      sessionRepository: mockSessionRepository,
    );
  });

  group('getProviderWorkOrders', () {
    final tCompanyIds = [
      EntityFactory.makeServiceProviderCompanyEntity().id,
      EntityFactory.makeServiceProviderCompanyEntity().id,
      EntityFactory.makeServiceProviderCompanyEntity().id,
    ];
    final tModels = [
      WorkOrderModel.fromEntity(EntityFactory.makeWorkOrderEntity()),
      WorkOrderModel.fromEntity(EntityFactory.makeWorkOrderEntity()),
      WorkOrderModel.fromEntity(EntityFactory.makeWorkOrderEntity()),
    ];

    test('returns mapped entities from remote when connected', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.getProviderWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => SuccessState(data: tModels));

      final result = await repository.getProviderWorkOrders(tCompanyIds);

      expect(result, isA<SuccessState<List<WorkOrderEntity>>>());
      expect(result.data?.length, tModels.length);
      verify(
        () => mockRemoteDataSource.getProviderWorkOrders(
          tCompanyIds,
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
    });

    test('never caches provider results into the local database', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.getProviderWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => SuccessState(data: tModels));

      await repository.getProviderWorkOrders(tCompanyIds);

      // Provider mode is online-only (V2 §1.4). Caching cross-company orders
      // would corrupt the internal-mode Drift scope.
      verifyNever(() => mockLocalDataSource.saveWorkOrders(any()));
    });

    test('fails with no internet instead of falling back to local', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.getProviderWorkOrders(tCompanyIds);

      expect(result, isA<FailureState<List<WorkOrderEntity>>>());
      verifyNever(
        () => mockRemoteDataSource.getProviderWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      );
      verifyNever(
        () => mockLocalDataSource.getWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      );
    });

    test('propagates remote failure', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      final tMessage = faker.lorem.sentence();
      when(
        () => mockRemoteDataSource.getProviderWorkOrders(
          any(),
          filter: any(named: 'filter'),
          pageSize: any(named: 'pageSize'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => FailureState(message: tMessage));

      final result = await repository.getProviderWorkOrders(tCompanyIds);

      expect(result, isA<FailureState<List<WorkOrderEntity>>>());
      expect(result.message, tMessage);
    });
  });

  group('getWorkOrderById in provider mode', () {
    final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity();
    final tWorkOrderModel = WorkOrderModel.fromEntity(tWorkOrderEntity);
    final tId = tWorkOrderEntity.id;

    test('fetches from remote without caching locally', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.getWorkOrderById(tId),
      ).thenAnswer((_) async => SuccessState(data: tWorkOrderModel));

      final result = await repository.getWorkOrderById(tId);

      expect(result, isA<SuccessState<WorkOrderEntity>>());
      expect(result.data, tWorkOrderEntity);
      verify(() => mockRemoteDataSource.getWorkOrderById(tId)).called(1);
      verifyNever(() => mockLocalDataSource.saveWorkOrder(any()));
    });

    test('returns failure without local fallback when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.getWorkOrderById(tId);

      expect(result, isA<FailureState<WorkOrderEntity>>());
      verifyNever(() => mockLocalDataSource.getWorkOrderById(any()));
    });
  });

  group('updateWorkOrder in provider mode', () {
    final tWorkOrderEntity = EntityFactory.makeWorkOrderEntity();
    final tWorkOrderModel = WorkOrderModel.fromEntity(tWorkOrderEntity);

    test('updates remotely without saving locally', () async {
      when(() => mockInternetClient.isConnected).thenReturn(true);
      when(
        () => mockRemoteDataSource.updateWorkOrder(tWorkOrderModel),
      ).thenAnswer((_) async => const SuccessState(data: true));

      final result = await repository.updateWorkOrder(tWorkOrderEntity);

      expect(result, const SuccessState(data: true));
      verify(
        () => mockRemoteDataSource.updateWorkOrder(tWorkOrderModel),
      ).called(1);
      verifyNever(() => mockLocalDataSource.saveWorkOrder(any()));
      verifyNever(() => mockOfflineTracker.recordOfflineAction());
    });

    test('fails without saving locally when offline', () async {
      when(() => mockInternetClient.isConnected).thenReturn(false);

      final result = await repository.updateWorkOrder(tWorkOrderEntity);

      expect(result, isA<FailureState<bool>>());
      verifyNever(() => mockLocalDataSource.saveWorkOrder(any()));
      verifyNever(() => mockOfflineTracker.recordOfflineAction());
    });
  });
}
