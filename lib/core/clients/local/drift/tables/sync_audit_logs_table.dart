import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_sync_audit_logs_company', columns: {#companyId})
@TableIndex(name: 'idx_sync_audit_logs_user', columns: {#userProfileId})
class SyncAuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get userProfileId => text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
