import 'package:clean_architecture/core/clients/local/drift/tables/areas_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/categories_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_assets_company', columns: {#companyId})
@TableIndex(name: 'idx_assets_area', columns: {#areaId})
@TableIndex(name: 'idx_assets_revision', columns: {#companyId, #revisionForecast})
@TableIndex.sql('CREATE UNIQUE INDEX assets_company_code_active_idx ON assets (company_id, code) WHERE deleted_at IS NULL;')
@TableIndex.sql('CREATE UNIQUE INDEX assets_company_serial_active_idx ON assets (company_id, serial_number) WHERE deleted_at IS NULL;')
class Assets extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get areaId => text().references(Areas, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get parentAssetId => text().nullable().references(Assets, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get serialNumber => text().nullable()();
  DateTimeColumn get installDate => dateTime().nullable()();
  DateTimeColumn get warrantyExpiration => dateTime().nullable()();
  DateTimeColumn get revisionForecast => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get criticality => text().withDefault(const Constant('medium'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
