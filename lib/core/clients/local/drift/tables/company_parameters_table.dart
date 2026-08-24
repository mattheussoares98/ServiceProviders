import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';

@TableIndex(name: 'idx_company_parameters_company', columns: {#companyId})
class CompanyParameters extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  IntColumn get maxOfflineDurationHours =>
      integer().withDefault(const Constant(2))();
  IntColumn get maxOfflinePendingRequests =>
      integer().withDefault(const Constant(10))();
  IntColumn get offlineAlertThrottleFrequency =>
      integer().withDefault(const Constant(3))();
  IntColumn get maxImageSizeMb => integer().withDefault(const Constant(20))();
  IntColumn get maxVideoSizeMb => integer().withDefault(const Constant(500))();
  IntColumn get maxPdfSizeMb => integer().withDefault(const Constant(10))();
  IntColumn get maxDocumentSizeMb => integer().withDefault(const Constant(5))();
  IntColumn get sandboxQuotaMb => integer().withDefault(const Constant(1024))();
  IntColumn get maxSyncAttempts => integer().withDefault(const Constant(3))();
  IntColumn get inviteExpiryHours =>
      integer().withDefault(const Constant(24))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {companyId},
  ];
}
