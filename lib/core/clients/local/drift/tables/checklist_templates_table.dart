import 'package:clean_architecture/core/clients/local/drift/tables/categories_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:drift/drift.dart';

class ChecklistTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
