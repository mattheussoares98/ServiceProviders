import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_companies_table.dart';

@TableIndex(
  name: 'idx_sp_invitations_company',
  columns: {#serviceProviderCompanyId},
)
@TableIndex(name: 'idx_sp_invitations_email', columns: {#email})
class ServiceProviderInvitations extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get serviceProviderCompanyId => text().references(
    ServiceProviderCompanies,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get inviteToken => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get acceptedAt => dateTime().nullable()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
