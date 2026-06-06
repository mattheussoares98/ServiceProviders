import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/work_orders_table.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_tasks_work_order', columns: {#workOrderId})
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text().references(WorkOrders, #id, onDelete: KeyAction.cascade)();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get completedById => text().nullable().references(UserProfiles, #id, onDelete: KeyAction.setNull)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
