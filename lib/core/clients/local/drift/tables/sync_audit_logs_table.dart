import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';

@TableIndex(name: 'idx_sync_audit_logs_company', columns: {#companyId})
@TableIndex(name: 'idx_sync_audit_logs_user', columns: {#userProfileId})
@TableIndex(
  name: 'idx_sync_audit_logs_status_created',
  columns: {#status, #createdAt},
)
class SyncAuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get userProfileId =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
