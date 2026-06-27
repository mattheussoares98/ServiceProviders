import 'package:clean_architecture/core/clients/local/drift/connection/unsupported.dart'
    if (dart.library.html) 'package:clean_architecture/core/clients/local/drift/connection/web.dart'
    if (dart.library.io) 'package:clean_architecture/core/clients/local/drift/connection/native.dart'
    as db_connect;
import 'package:clean_architecture/core/clients/local/drift/tables/app_settings_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/areas_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/assets_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/attachments_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/categories_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/checklist_items_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/checklist_templates_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/companies_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/company_parameters_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/locations_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/maintenance_plans_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/permission_groups_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/sync_audit_logs_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/tasks_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/user_profiles_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/user_sessions_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/work_order_change_requests_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/work_order_history_table.dart';
import 'package:clean_architecture/core/clients/local/drift/tables/work_orders_table.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

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
    WorkOrders,
    Tasks,
    Attachments,
    WorkOrderChangeRequests,
    CompanyParameters,
    SyncAuditLogs,
    WorkOrderHistory,
  ],
)
@LazySingleton()
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(db_connect.connect());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
        await customStatement('PRAGMA foreign_keys = OFF;');

        await m.deleteTable('assets');
        await m.deleteTable('areas');
        await m.deleteTable('categories');
        await m.deleteTable('locations');

        await m.createTable(locations);
        await m.createTable(categories);
        await m.createTable(areas);
        await m.createTable(assets);

        await customStatement('PRAGMA foreign_keys = ON;');
      }
      if (from < 6) {
        // Recreate tables to apply the case-insensitive COLLATE NOCASE constraints.
        // Disable foreign keys temporarily during table recreation
        await customStatement('PRAGMA foreign_keys = OFF;');

        await m.deleteTable('assets');
        await m.deleteTable('areas');
        await m.deleteTable('categories');
        await m.deleteTable('locations');

        await m.createTable(locations);
        await m.createTable(categories);
        await m.createTable(areas);
        await m.createTable(assets);

        await customStatement('PRAGMA foreign_keys = ON;');
      }
      if (from < 7) {
        await m.addColumn(userProfiles, userProfiles.permissions);
      }
    },
  );
}

