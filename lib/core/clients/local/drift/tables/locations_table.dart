import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:drift/drift.dart';

class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {companyId, name}
      ];
}
