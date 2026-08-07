import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_companies_table.dart';

@TableIndex(name: 'idx_spp_company', columns: {#serviceProviderCompanyId})
@TableIndex(name: 'idx_spp_auth_user', columns: {#authUserId})
@TableIndex(name: 'idx_spp_email', columns: {#email})
class ServiceProviderProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get authUserId => text().nullable()();
  TextColumn get serviceProviderCompanyId => text().references(
    ServiceProviderCompanies,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phone => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
