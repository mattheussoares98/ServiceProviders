import 'package:drift/drift.dart';

class Companies extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get cnpj => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
