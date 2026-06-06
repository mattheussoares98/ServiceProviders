import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_permission_groups_company', columns: {#companyId})
class PermissionGroups extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get permissions => text().withDefault(const Constant('[]'))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
