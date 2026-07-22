import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';

@TableIndex.sql(
  'CREATE UNIQUE INDEX sectors_company_name_active_idx ON sectors (company_id, name COLLATE NOCASE) WHERE deleted_at IS NULL;',
)
class Sectors extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
