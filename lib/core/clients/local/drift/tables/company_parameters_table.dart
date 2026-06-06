import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_company_parameters_company', columns: {#companyId})
class CompanyParameters extends Table {
  TextColumn get id => text()();
  TextColumn get companyId => text().references(Companies, #id, onDelete: KeyAction.cascade)();
  IntColumn get maxOfflineDurationHours => integer().withDefault(const Constant(2))();
  IntColumn get maxOfflinePendingRequests => integer().withDefault(const Constant(10))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {companyId}
      ];
}
