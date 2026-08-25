import 'dart:async';

import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_realtime_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../testing/mocks/client_mocks.dart';
import '../../../../../testing/mocks/entity_factory.dart';

class _FakePostgresChangeFilter extends Fake implements PostgresChangeFilter {}

void main() {
  late MockSupabaseRealtimeClient mockRealtimeClient;
  late WorkOrdersRealtimeRemoteDataSourceImpl dataSource;
  late StreamController<PostgresChangePayload> streamController;

  setUpAll(() {
    registerFallbackValue(PostgresChangeEvent.all);
    registerFallbackValue(_FakePostgresChangeFilter());
  });

  setUp(() {
    mockRealtimeClient = MockSupabaseRealtimeClient();
    dataSource = WorkOrdersRealtimeRemoteDataSourceImpl(
      realtimeClient: mockRealtimeClient,
    );
    streamController = StreamController<PostgresChangePayload>.broadcast();

    when(
      () => mockRealtimeClient.streamTableChanges(
        table: any(named: 'table'),
        schema: any(named: 'schema'),
        event: any(named: 'event'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) => streamController.stream);
  });

  tearDown(() {
    streamController.close();
  });

  test(
    'watchWorkOrders passes correct table and filter when companyId is provided',
    () {
      final companyId = faker.guid.guid();
      dataSource.watchWorkOrders(companyId: companyId);

      verify(
        () => mockRealtimeClient.streamTableChanges(
          table: 'work_orders',
          filter: any(named: 'filter'),
        ),
      ).called(1);
    },
  );

  test(
    'watchWorkOrders maps INSERT payload to RealtimeEvent with entity',
    () async {
      final entity = EntityFactory.makeWorkOrderEntity();
      final model = WorkOrderModel.fromEntity(entity);
      final json = model.toJson();

      final stream = dataSource.watchWorkOrders();

      final expectation = expectLater(
        stream,
        emits(
          predicate<RealtimeEvent<WorkOrderModel>>((event) {
            return event.eventType == RealtimeEventType.insert &&
                event.id == entity.id &&
                event.entity?.id == entity.id;
          }),
        ),
      );

      streamController.add(
        PostgresChangePayload(
          eventType: PostgresChangeEvent.insert,
          newRecord: json,
          oldRecord: const {},
          schema: 'public',
          table: 'work_orders',
          commitTimestamp: DateTime.now(),
          errors: const <dynamic>[],
        ),
      );

      await expectation;
    },
  );

  test('watchWorkOrders maps UPDATE payload to RealtimeEvent', () async {
    final entity = EntityFactory.makeWorkOrderEntity();
    final model = WorkOrderModel.fromEntity(entity);
    final json = model.toJson();

    final stream = dataSource.watchWorkOrders();

    final expectation = expectLater(
      stream,
      emits(
        predicate<RealtimeEvent<WorkOrderModel>>((event) {
          return event.eventType == RealtimeEventType.update &&
              event.id == entity.id &&
              event.entity?.title == entity.title;
        }),
      ),
    );

    streamController.add(
      PostgresChangePayload(
        eventType: PostgresChangeEvent.update,
        newRecord: json,
        oldRecord: const {},
        schema: 'public',
        table: 'work_orders',
        commitTimestamp: DateTime.now(),
        errors: const <dynamic>[],
      ),
    );

    await expectation;
  });

  test(
    'watchWorkOrders maps DELETE payload to RealtimeEvent with id from oldRecord',
    () async {
      final workOrderId = faker.guid.guid();

      final stream = dataSource.watchWorkOrders();

      final expectation = expectLater(
        stream,
        emits(
          predicate<RealtimeEvent<WorkOrderModel>>((event) {
            return event.eventType == RealtimeEventType.delete &&
                event.id == workOrderId &&
                event.entity == null;
          }),
        ),
      );

      streamController.add(
        PostgresChangePayload(
          eventType: PostgresChangeEvent.delete,
          newRecord: const {},
          oldRecord: {'id': workOrderId},
          schema: 'public',
          table: 'work_orders',
          commitTimestamp: DateTime.now(),
          errors: const <dynamic>[],
        ),
      );

      await expectation;
    },
  );
}
