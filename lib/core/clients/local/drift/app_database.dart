import 'dart:io';

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
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(userProfiles, userProfiles.isAdmin);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
