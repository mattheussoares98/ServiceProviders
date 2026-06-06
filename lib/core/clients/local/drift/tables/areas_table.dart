import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/locations_table.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_areas_location', columns: {#locationId})
class Areas extends Table {
  TextColumn get id => text()();
  TextColumn get locationId => text().references(Locations, #id, onDelete: KeyAction.cascade)();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get floor => text().nullable()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
