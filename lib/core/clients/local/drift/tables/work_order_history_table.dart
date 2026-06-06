import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/work_orders_table.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_work_order_history_work_order', columns: {#workOrderId})
@TableIndex(name: 'idx_work_order_history_company', columns: {#companyId})
class WorkOrderHistory extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text().references(WorkOrders, #id, onDelete: KeyAction.cascade)();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get action => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
