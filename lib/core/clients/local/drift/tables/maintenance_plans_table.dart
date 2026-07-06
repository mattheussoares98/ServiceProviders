import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/assets_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/checklist_templates_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/locations_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';

@TableIndex(name: 'idx_maintenance_plans_company', columns: {#companyId})
class MaintenancePlans extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get assetId =>
      text().nullable().references(Assets, #id, onDelete: KeyAction.setNull)();
  TextColumn get locationId => text().nullable().references(
    Locations,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get frequency => text()();
  IntColumn get dayOfWeek => integer().nullable()();
  IntColumn get dayOfMonth => integer().nullable()();
  IntColumn get monthOfYear => integer().nullable()();
  TextColumn get checklistTemplateId => text().nullable().references(
    ChecklistTemplates,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get assignedToId => text().nullable().references(
    UserProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastGeneratedAt => dateTime().nullable()();
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
