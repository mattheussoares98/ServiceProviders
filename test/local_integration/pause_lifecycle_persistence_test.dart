import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pauses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pauses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/work_order_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  PauseLocalDataSourceImpl pauses() =>
      PauseLocalDataSourceImpl(database: fixture.database);
  WorkOrdersLocalDataSourceImpl orders() =>
      WorkOrdersLocalDataSourceImpl(database: fixture.database);
  final order = WorkOrderFactory.makeWorkOrderEntity().copyWith(
    status: WorkOrderStatus.inProgress,
    annulCompletedAt: true,
    attachments: [],
  );
  final request = WorkOrderFactory.makePauseRequestEntity().copyWith(
    companyId: order.companyId,
    workOrderId: order.id,
    eventType: PauseEventType.pause,
    status: PauseRequestStatus.pending,
    annulResumedAt: true,
    annulResumedById: true,
    annulReviewedById: true,
    annulReviewObservation: true,
  );
  setUp(() async {
    fixture = LocalDatabaseFixture();
    expect(
      (await orders().saveWorkOrder(WorkOrderModel.fromEntity(order))).data,
      isTrue,
    );
  });
  tearDown(() => fixture.dispose());

  test(
    'pause request and resume keep order and event consistent after restart',
    () async {
      expect(
        (await pauses().savePauseRequest(
          PauseRequestModel.fromEntity(request),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await orders().getWorkOrderById(order.id)).data!.status,
        WorkOrderStatus.onHold,
      );
      expect(
        (await pauses().getPauseRequests(order.id)).data!.single.resumedAt,
        isNull,
      );
      final resumedAt = DateTime.utc(2026, 9, 19, 14);
      expect(
        (await pauses().resumeWork(
          id: request.id,
          workOrderId: order.id,
          resumedAt: resumedAt,
          resumedById: order.createdById!,
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await orders().getWorkOrderById(order.id)).data!.status,
        WorkOrderStatus.inProgress,
      );
      final event = (await pauses().getPauseRequests(order.id)).data!.single;
      expect(event.resumedAt, resumedAt);
      expect(event.resumedById, order.createdById);
    },
  );

  for (final approved in [true, false]) {
    test(
      'completion ${approved ? 'approval' : 'rejection'} persists both records after reopening',
      () async {
        expect(
          (await pauses().savePauseRequest(
            PauseRequestModel.fromEntity(
              request.copyWith(eventType: PauseEventType.completion),
            ),
          )).data,
          isTrue,
        );
        await fixture.reopen();
        expect(
          (await orders().getWorkOrderById(order.id)).data!.status,
          WorkOrderStatus.pendingConclusionApproval,
        );
        final status = approved
            ? PauseRequestStatus.approved
            : PauseRequestStatus.rejected;
        expect(
          (await pauses().reviewCompletion(
            id: request.id,
            workOrderId: order.id,
            status: status.value,
            reviewedById: order.createdById!,
            reviewObservation: 'Revisado',
            completionReason: 'Inspeção finalizada',
          )).data,
          isTrue,
        );
        await fixture.reopen();
        final event = (await pauses().getPauseRequests(order.id)).data!.single;
        final updated = (await orders().getWorkOrderById(order.id)).data!;
        expect(event.status, status);
        expect(event.reviewedById, order.createdById);
        expect(event.reviewObservation, 'Revisado');
        expect(
          updated.status,
          approved ? WorkOrderStatus.completed : WorkOrderStatus.inProgress,
        );
        expect(updated.completedAt, approved ? isNotNull : isNull);
        if (approved) expect(updated.completionReason, 'Inspeção finalizada');
      },
    );
  }

  test(
    'failed order update rolls back completion review instead of persisting half a transaction',
    () async {
      expect(
        (await pauses().savePauseRequest(
          PauseRequestModel.fromEntity(
            request.copyWith(eventType: PauseEventType.completion),
          ),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      await fixture.database.customStatement('''
      CREATE TRIGGER reject_order_update
      BEFORE UPDATE ON work_orders BEGIN
      SELECT RAISE(ABORT, 'injected storage failure'); END''');
      final result = await pauses().reviewCompletion(
        id: request.id,
        workOrderId: order.id,
        status: PauseRequestStatus.approved.value,
        reviewedById: order.createdById!,
      );
      expect(result, isA<FailureState<bool>>());
      await fixture.reopen();
      final event = (await pauses().getPauseRequests(order.id)).data!.single;
      expect(event.status, PauseRequestStatus.pending);
      expect(event.reviewedById, isNull);
      expect(
        (await orders().getWorkOrderById(order.id)).data!.status,
        WorkOrderStatus.pendingConclusionApproval,
      );
    },
  );

  test(
    'pause reason rename, deactivation, and removal persist across reopening',
    () async {
      final reason = WorkOrderFactory.makePauseReasonEntity().copyWith(
        companyId: order.companyId,
      );
      expect(
        (await pauses().savePauseReason(
          PauseReasonModel.fromEntity(reason),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await pauses().getPauseReasons(order.companyId)).data!.single.name,
        reason.name,
      );
      expect(
        (await pauses().savePauseReason(
          PauseReasonModel.fromEntity(
            reason.copyWith(name: 'Aguardando peça', isActive: false),
          ),
        )).data,
        isTrue,
      );
      await fixture.reopen();
      final changed = (await pauses().getPauseReasons(
        order.companyId,
      )).data!.single;
      expect(changed.name, 'Aguardando peça');
      expect(changed.isActive, isFalse);
      expect((await pauses().deletePauseReason(reason.id)).data, isTrue);
      await fixture.reopen();
      expect((await pauses().getPauseReasons(order.companyId)).data, isEmpty);
    },
  );
}
