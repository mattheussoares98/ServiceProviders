import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/connection/unsupported.dart'
    if (dart.library.html) 'package:o_jogo_da_obra/core/clients/local/drift/connection/web.dart'
    if (dart.library.io) 'package:o_jogo_da_obra/core/clients/local/drift/connection/native.dart'
    as db_connect;
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/app_settings_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/areas_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/assets_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/attachments_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/categories_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/checklist_items_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/checklist_templates_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/company_parameters_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/locations_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/maintenance_plans_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/pause_reasons_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/permission_groups_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/sectors_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_companies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_invitations_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/service_provider_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/sla_policies_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/sync_audit_logs_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/tasks_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/user_sessions_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_order_change_requests_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_order_history_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_order_observations_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_order_pause_requests_table.dart';
import 'package:o_jogo_da_obra/core/clients/local/drift/tables/work_orders_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    AppSettings,
    UserSessions,
    Companies,
    PermissionGroups,
    UserProfiles,
    Locations,
    Areas,
    Categories,
    Assets,
    ChecklistTemplates,
    ChecklistItems,
    MaintenancePlans,
    ServiceProviderCompanies,
    ServiceProviderProfiles,
    ServiceProviderInvitations,
    WorkOrders,
    Tasks,
    Attachments,
    WorkOrderChangeRequests,
    CompanyParameters,
    SyncAuditLogs,
    WorkOrderHistory,
    SlaPolicies,
    PauseReasons,
    WorkOrderPauseRequests,
    Sectors,
    WorkOrderObservations,
  ],
)
@LazySingleton()
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(db_connect.connect());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 29;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // Local Drift SQLite operates as an offline read-through cache for Supabase.
      // Remote API responses arrive asynchronously and independently (e.g. child records
      // like user profiles, observations, or attachments can be cached before parent records
      // like companies or work orders are fetched). Disabling runtime foreign key enforcement
      // in the local cache prevents SQLite constraint failures (code 787) on out-of-order writes
      // while preserving schema definitions, indexes, and Drift join queries. Relational
      // integrity is enforced server-side by PostgreSQL on Supabase.
      await customStatement('PRAGMA foreign_keys = OFF;');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(userProfiles, userProfiles.isAdmin);
      }
      if (from < 3) {
        await m.addColumn(appSettings, appSettings.pushNotificationsEnabled);
      }
      if (from < 4) {
        await m.addColumn(locations, locations.number);
        await m.addColumn(locations, locations.complement);
        await m.addColumn(locations, locations.neighborhood);
        await m.addColumn(locations, locations.postalCode);
      }
      if (from < 5) {
        // Disable foreign keys temporarily during table recreation

        await m.deleteTable('assets');
        await m.deleteTable('areas');
        await m.deleteTable('categories');
        await m.deleteTable('locations');

        await m.createTable(locations);
        await m.createTable(categories);
        await m.createTable(areas);
        await m.createTable(assets);
      }
      if (from < 6) {
        // Recreate tables to apply the case-insensitive COLLATE NOCASE constraints.
        // Disable foreign keys temporarily during table recreation

        await m.deleteTable('assets');
        await m.deleteTable('areas');
        await m.deleteTable('categories');
        await m.deleteTable('locations');

        await m.createTable(locations);
        await m.createTable(categories);
        await m.createTable(areas);
        await m.createTable(assets);
      }
      if (from < 7) {
        await m.addColumn(userProfiles, userProfiles.permissions);
      }
      if (from < 8) {
        await m.addColumn(attachments, attachments.originalPath);
      }
      if (from < 9) {
        await m.addColumn(attachments, attachments.lastAccessedAt);
      }
      if (from < 10) {
        await m.createTable(serviceProviderCompanies);
        await m.createTable(serviceProviderProfiles);
        await m.addColumn(workOrders, workOrders.serviceProviderCompanyId);
        await m.addColumn(workOrders, workOrders.providerProfileId);
        await m.addColumn(workOrders, workOrders.openedBy);
      }
      if (from < 11) {
        await m.addColumn(appSettings, appSettings.selectedMode);
      }
      if (from < 12) {
        await m.createTable(slaPolicies);
        await m.createTable(pauseReasons);
        await m.createTable(workOrderPauseRequests);
        await m.addColumn(workOrders, workOrders.slaPolicyId);
        await m.addColumn(workOrders, workOrders.slaDeadlineAt);
        await m.addColumn(workOrders, workOrders.slaBreached);
        await m.addColumn(workOrders, workOrders.netActiveDuration);
      }
      if (from < 13) {
        await m.createTable(sectors);
        await m.deleteTable('work_order_pause_requests');
        await m.createTable(workOrderPauseRequests);
      }
      if (from < 14) {
        await m.createTable(workOrderObservations);
      }
      if (from < 15) {
        await m.addColumn(workOrders, workOrders.completionReason);
        await m.addColumn(workOrders, workOrders.completionResponsibility);
        await m.addColumn(workOrders, workOrders.completionSectorId);
      }
      if (from < 16) {
        await m.createTable(serviceProviderInvitations);
      }
      if (from < 17) {
        await m.addColumn(appSettings, appSettings.selectedCompanyId);
      }
      if (from < 18) {
        await m.addColumn(workOrders, workOrders.areaId);
      }
      if (from < 20) {
        await m.addColumn(
          serviceProviderCompanies,
          serviceProviderCompanies.invitationStatus,
        );
      }
      if (from < 21) {
        await m.addColumn(
          workOrderPauseRequests,
          workOrderPauseRequests.resumedById,
        );
      }
      if (from < 22) {
        await m.addColumn(
          workOrderPauseRequests,
          workOrderPauseRequests.eventType,
        );
      }
      if (from < 23) {
        await m.deleteTable('work_order_pause_requests');
        await m.createTable(workOrderPauseRequests);
      }
      if (from < 24) {
        // author_id became nullable and author_provider_profile_id was added;
        // SQLite cannot drop a NOT NULL, so the table is recreated. The rows
        // are a read-through cache and refetch on the next load.
        await m.deleteTable('work_order_observations');
        await m.createTable(workOrderObservations);
      }
      if (from < 25) {
        // created_by_id became nullable and created_by_provider_profile_id was
        // added; SQLite cannot drop a NOT NULL, so the table is recreated. The
        // rows are a read-through cache and refetch on the next load.
        await m.deleteTable('work_orders');
        await m.createTable(workOrders);
      }
      if (from < 26) {
        await m.deleteTable('sync_audit_logs');
        await m.createTable(syncAuditLogs);
      }
      if (from < 27) {
        await m.deleteTable('company_parameters');
        await m.createTable(companyParameters);
      }
      if (from < 28) {
        await m.deleteTable('company_parameters');
        await m.createTable(companyParameters);
        await m.addColumn(workOrders, workOrders.advanceWarningSentAt);
        await m.addColumn(workOrders, workOrders.lastEscalationLevel);
        await m.addColumn(workOrders, workOrders.lastEscalationAt);
      }
      if (from < 29) {
        await m.addColumn(userProfiles, userProfiles.lastAccessAt);
      }
    },
  );
}
