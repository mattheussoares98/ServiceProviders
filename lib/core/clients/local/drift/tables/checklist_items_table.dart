import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/checklist_templates_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';

class ChecklistItems extends Table {
  TextColumn get id => text()();
  TextColumn get templateId =>
      text().references(ChecklistTemplates, #id, onDelete: KeyAction.cascade)();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  TextColumn get type => text().withDefault(const Constant('boolean'))();
  BoolColumn get isRequired => boolean().withDefault(const Constant(false))();
  TextColumn get options => text().nullable()(); // JSON array
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
