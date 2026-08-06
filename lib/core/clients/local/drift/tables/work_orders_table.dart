import 'package:drift/drift.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/areas_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/assets_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/locations_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/maintenance_plans_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/sectors_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/sla_policies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';

@TableIndex(name: 'idx_work_orders_company', columns: {#companyId})
@TableIndex(name: 'idx_work_orders_status', columns: {#companyId, #status})
@TableIndex(
  name: 'idx_work_orders_assigned',
  columns: {#companyId, #assignedToId},
)
@TableIndex(
  name: 'idx_work_orders_scheduled',
  columns: {#companyId, #scheduledDate},
)
class WorkOrders extends Table {
  TextColumn get id => text()();
  TextColumn get companyId =>
      text().references(Companies, #id, onDelete: KeyAction.cascade)();
  TextColumn get assetId =>
      text().nullable().references(Assets, #id, onDelete: KeyAction.setNull)();
  TextColumn get locationId =>
      text().references(Locations, #id, onDelete: KeyAction.cascade)();
  TextColumn get areaId => text().nullable().references(
    Areas,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get assignedToId => text().nullable().references(
    UserProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get createdById =>
      text().references(UserProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get maintenancePlanId => text().nullable().references(
    MaintenancePlans,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get type => text().withDefault(const Constant('corrective'))();
  DateTimeColumn get scheduledDate => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get estimatedDuration => integer().nullable()();
  IntColumn get actualDuration => integer().nullable()();
  RealColumn get laborCost => real().nullable()();
  RealColumn get partsCost => real().nullable()();
  RealColumn get totalCost => real().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get serviceProviderCompanyId => text().nullable().references(
    ServiceProviderCompanies,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get providerProfileId => text().nullable().references(
    ServiceProviderProfiles,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get openedBy =>
      text().withDefault(const Constant('internal'))();
  TextColumn get slaPolicyId => text().nullable().references(
        SlaPolicies,
        #id,
        onDelete: KeyAction.setNull,
      )();
  DateTimeColumn get slaDeadlineAt => dateTime().nullable()();
  BoolColumn get slaBreached => boolean().nullable()();
  IntColumn get netActiveDuration => integer().nullable()();
  TextColumn get completionReason => text().nullable()();
  TextColumn get completionResponsibility => text().nullable()();
  TextColumn get completionSectorId => text().nullable().references(
        Sectors,
        #id,
        onDelete: KeyAction.setNull,
      )();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

