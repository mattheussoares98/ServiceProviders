import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_orders_table.dart';

@TableIndex(
  name: 'idx_work_order_change_requests_work_order',
  columns: {#workOrderId},
)
@TableIndex(
  name: 'idx_work_order_change_requests_status',
  columns: {#companyId, #status},
)
class WorkOrderChangeRequests extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId =>
      text().references(WorkOrders, #id, onDelete: KeyAction.cascade)();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get requestedById =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get changeType =>
      text()(); // enum: add_task, add_attachment, update_notes, fill_checklist
  TextColumn get changeData => text()(); // JSON string
  TextColumn get status => text().withDefault(
    const Constant('pending'),
  )(); // enum: pending, approved, rejected
  TextColumn get reviewedById => text().nullable().references(
    UserProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get rejectionReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
