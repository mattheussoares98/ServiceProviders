import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';

class PauseReasons extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
