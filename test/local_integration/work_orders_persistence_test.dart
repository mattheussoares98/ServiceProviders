import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/task_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

import '../../testing/mocks/factories/local_database_fixture.dart';
import '../../testing/mocks/factories/work_order_factory.dart';

void main() {
  late LocalDatabaseFixture fixture;
  WorkOrdersLocalDataSourceImpl source() =>
      WorkOrdersLocalDataSourceImpl(database: fixture.database);
  setUp(() => fixture = LocalDatabaseFixture());
  tearDown(() => fixture.dispose());

  test(
    'create, edit, delete, and restore retain the same order across restarts',
    () async {
      final order = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        title: 'Inspeção da bomba',
        attachments: [],
      );
      expect(
        (await source().saveWorkOrder(WorkOrderModel.fromEntity(order))).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getWorkOrders(order.companyId)).data!.single.title,
        order.title,
      );
      final updated = order.copyWith(
        title: 'Reparo da bomba',
        annulNotes: true,
        annulAssignedToId: true,
        price: 0,
      );
      expect(
        (await source().saveWorkOrder(WorkOrderModel.fromEntity(updated))).data,
        isTrue,
      );
      await fixture.reopen();
      var row = (await source().getWorkOrderById(order.id)).data!;
      expect(row.title, updated.title);
      expect(row.notes, isNull);
      expect(row.assignedToId, isNull);
      expect(row.price, 0);
      expect((await source().deleteWorkOrder(order.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getWorkOrders(order.companyId)).data, isEmpty);
      expect(
        (await source().getWorkOrders(
          order.companyId,
          filter: const WorkOrderFilter(onlyDeleted: true),
        )).data!.single.id,
        order.id,
      );
      expect((await source().restoreWorkOrder(order.id)).data, isTrue);
      await fixture.reopen();
      row = (await source().getWorkOrders(order.companyId)).data!.single;
      expect(row.id, order.id);
      expect(row.title, updated.title);
      expect(row.deletedAt, isNull);
      expect(
        (await source().getWorkOrders(
          order.companyId,
          filter: const WorkOrderFilter(onlyDeleted: true),
        )).data,
        isEmpty,
      );
    },
  );

  test('status changes move between filtered lists after restarting', () async {
    final order = WorkOrderFactory.makeWorkOrderEntity().copyWith(
      attachments: [],
      status: WorkOrderStatus.open,
    );
    expect(
      (await source().saveWorkOrder(WorkOrderModel.fromEntity(order))).data,
      isTrue,
    );
    await fixture.reopen();
    expect(
      (await source().getWorkOrders(
        order.companyId,
        filter: const WorkOrderFilter(statuses: [WorkOrderStatus.open]),
      )).data!.single.id,
      order.id,
    );
    final completed = order.copyWith(
      status: WorkOrderStatus.completed,
      completedAt: DateTime.utc(2026, 9, 19, 12),
      actualDuration: 3600,
    );
    expect(
      (await source().saveWorkOrder(WorkOrderModel.fromEntity(completed))).data,
      isTrue,
    );
    await fixture.reopen();
    expect(
      (await source().getWorkOrders(
        order.companyId,
        filter: const WorkOrderFilter(statuses: [WorkOrderStatus.open]),
      )).data,
      isEmpty,
    );
    final row = (await source().getWorkOrders(
      order.companyId,
      filter: const WorkOrderFilter(statuses: [WorkOrderStatus.completed]),
    )).data!.single;
    expect(row.id, order.id);
    expect(row.completedAt, completed.completedAt);
    expect(row.actualDuration, 3600);
  });

  test(
    'company queries and delete remain isolated for identical order titles',
    () async {
      final a = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        title: 'Inspeção',
        attachments: [],
      );
      final b = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        title: 'Inspeção',
        attachments: [],
      );
      final batch = [
        WorkOrderModel.fromEntity(a),
        WorkOrderModel.fromEntity(b),
      ];
      expect((await source().saveWorkOrders(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().saveWorkOrders(batch)).data, isTrue);
      await fixture.reopen();
      expect((await source().getWorkOrders(a.companyId)).data!.single.id, a.id);
      expect((await source().getWorkOrders(b.companyId)).data!.single.id, b.id);
      expect((await source().deleteWorkOrder(a.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getActiveWorkOrderIds(a.companyId)).data, isEmpty);
      expect((await source().getActiveWorkOrderIds(b.companyId)).data, [b.id]);
    },
  );

  test(
    'task completion, reopening, and deletion persist without affecting other tasks',
    () async {
      final order = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        attachments: [],
      );
      final task = WorkOrderFactory.makeTaskEntity().copyWith(
        workOrderId: order.id,
        companyId: order.companyId,
        isCompleted: false,
        annulCompletedAt: true,
        annulCompletedById: true,
      );
      final other = WorkOrderFactory.makeTaskEntity();
      expect(
        (await source().saveWorkOrder(WorkOrderModel.fromEntity(order))).data,
        isTrue,
      );
      expect(
        (await source().saveTask(TaskModel.fromEntity(task))).data,
        isTrue,
      );
      expect(
        (await source().saveTask(TaskModel.fromEntity(other))).data,
        isTrue,
      );
      await fixture.reopen();
      expect(
        (await source().getTasksByWorkOrder(order.id)).data!.single.isCompleted,
        isFalse,
      );
      final completed = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.utc(2026, 9, 19),
        completedById: order.createdById,
      );
      expect(
        (await source().saveTask(TaskModel.fromEntity(completed))).data,
        isTrue,
      );
      await fixture.reopen();
      var row = (await source().getTasksByWorkOrder(order.id)).data!.single;
      expect(row.isCompleted, isTrue);
      expect(row.completedAt, completed.completedAt);
      expect(row.completedById, completed.completedById);
      expect(
        (await source().saveTask(TaskModel.fromEntity(task))).data,
        isTrue,
      );
      await fixture.reopen();
      row = (await source().getTasksByWorkOrder(order.id)).data!.single;
      expect(row.isCompleted, isFalse);
      expect(row.completedAt, isNull);
      expect(row.completedById, isNull);
      expect((await source().deleteTask(task.id)).data, isTrue);
      await fixture.reopen();
      expect((await source().getTasksByWorkOrder(order.id)).data, isEmpty);
      expect(
        (await source().getTasksByWorkOrder(other.workOrderId)).data!.single.id,
        other.id,
      );
    },
  );
}
