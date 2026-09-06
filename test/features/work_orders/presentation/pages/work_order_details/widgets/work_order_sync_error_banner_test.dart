import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_queue_item_entity.dart';
import 'package:o_jogo_da_obra/features/sync/domain/entities/sync_status.dart';
import 'package:o_jogo_da_obra/features/sync/domain/services/sync_engine.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/pages/work_order_details/widgets/work_order_sync_error_banner.dart';

import '../../../../../../../testing/mocks/factories/system_factory.dart';
import '../../../../../../../testing/mocks/factories/work_order_factory.dart';
import '../../../../../../../testing/mocks/services.dart';

void main() {
  late MockSyncEngine mockSyncEngine;

  setUp(() {
    mockSyncEngine = MockSyncEngine();
    GetIt.I.registerSingleton<SyncEngine>(mockSyncEngine);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('WorkOrderSyncErrorBanner', () {
    testWidgets(
      'renders nothing (SizedBox.shrink) when stream emits empty list',
      (tester) async {
        final workOrder = WorkOrderFactory.makeWorkOrderEntity();
        when(
          () => mockSyncEngine.watchDeadLetterItemsForEntity(workOrder.id),
        ).thenAnswer((_) => Stream.value([]));

        await tester.pumpWidget(
          buildTestableWidget(WorkOrderSyncErrorBanner(workOrder: workOrder)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Falha na sincronização'), findsNothing);
        expect(find.text('Tentar novamente'), findsNothing);
      },
    );

    testWidgets(
      'renders banner with error details when dead-letter items exist',
      (tester) async {
        final workOrder = WorkOrderFactory.makeWorkOrderEntity();
        final deadLetterItem = SystemFactory.makeSyncQueueItemEntity().copyWith(
          entityId: workOrder.id,
          status: SyncStatus.deadLetter,
          lastError: '400 Bad Request: Constraint violation',
        );

        when(
          () => mockSyncEngine.watchDeadLetterItemsForEntity(workOrder.id),
        ).thenAnswer((_) => Stream.value([deadLetterItem]));

        await tester.pumpWidget(
          buildTestableWidget(WorkOrderSyncErrorBanner(workOrder: workOrder)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Falha na sincronização'), findsOneWidget);
        expect(
          find.text(
            'As alterações feitas offline não puderam ser sincronizadas com o servidor.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('400 Bad Request: Constraint violation'),
          findsOneWidget,
        );
        expect(find.text('Tentar novamente'), findsOneWidget);
      },
    );

    testWidgets('tapping Tentar novamente invokes retryEntity on SyncEngine', (
      tester,
    ) async {
      final workOrder = WorkOrderFactory.makeWorkOrderEntity();
      final deadLetterItem = SystemFactory.makeSyncQueueItemEntity().copyWith(
        entityId: workOrder.id,
        status: SyncStatus.deadLetter,
        lastError: 'Permanent sync error',
      );

      final controller =
          StreamController<List<SyncQueueItemEntity>>.broadcast();
      when(
        () => mockSyncEngine.watchDeadLetterItemsForEntity(workOrder.id),
      ).thenAnswer((_) => controller.stream);
      when(
        () => mockSyncEngine.retryEntity(workOrder.id),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestableWidget(WorkOrderSyncErrorBanner(workOrder: workOrder)),
      );

      controller.add([deadLetterItem]);
      await tester.pumpAndSettle();

      expect(find.text('Tentar novamente'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      verify(() => mockSyncEngine.retryEntity(workOrder.id)).called(1);

      await controller.close();
    });
  });
}
