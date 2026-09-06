import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/supabase_auth_client.dart';
import 'package:o_jogo_da_obra/features/access_logs/data/data_sources/access_logs_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/assets/data/data_sources/assets_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/attachments/data/data_sources/attachments_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/checklists/data/data_sources/checklists_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/configurations/data/data_sources/configurations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/locations/data/data_sources/locations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/notifications/data/data_sources/notifications_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/service_providers/data/data_sources/service_provider_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/data_sources/sla_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/users/data/data_sources/users_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_order_observations_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_realtime_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/work_orders_remote_data_source.dart';

/// Every Supabase-backed remote data source, all bound to one identity's clients.
///
/// Data sources are stateless holders of the two clients, so building the whole
/// bundle per identity is cheap and keeps a test from accidentally issuing a call
/// as the wrong user. Sources are created eagerly and stored `final`.
///
/// Excluded on purpose: the two legacy Dio-backed sources (maintenance plans,
/// home), which do not take a `SupabaseDatabaseClient`.
final class IntegrationDataSources {
  IntegrationDataSources._({
    required this.accessLogs,
    required this.assets,
    required this.attachments,
    required this.auth,
    required this.categories,
    required this.checklists,
    required this.company,
    required this.configurations,
    required this.locations,
    required this.notifications,
    required this.sectors,
    required this.serviceProviders,
    required this.sla,
    required this.users,
    required this.pause,
    required this.observations,
    required this.workOrders,
    required this.workOrdersRealtime,
  });

  /// Builds the bundle for a single identity's clients.
  factory IntegrationDataSources.forClient({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtime,
    required SupabaseAuthClient auth,
  }) {
    return IntegrationDataSources._(
      accessLogs: AccessLogsRemoteDataSourceImpl(database: database),
      assets: AssetsRemoteDataSourceImpl(
        database: database,
        realtimeClient: realtime,
      ),
      attachments: AttachmentsRemoteDataSourceImpl(
        database: database,
        realtimeClient: realtime,
      ),
      auth: AuthRemoteDataSourceImpl(
        supabaseAuth: auth,
        supabaseDatabase: database,
      ),
      categories: CategoriesRemoteDataSourceImpl(database: database),
      checklists: ChecklistsRemoteDataSourceImpl(
        database: database,
        realtimeClient: realtime,
      ),
      company: CompanyRemoteDataSourceImpl(database: database),
      configurations: ConfigurationsRemoteDataSourceImpl(database: database),
      locations: LocationsRemoteDataSourceImpl(
        database: database,
        realtimeClient: realtime,
      ),
      notifications: NotificationsRemoteDataSourceImpl(database: database),
      sectors: SectorsRemoteDataSourceImpl(database: database),
      serviceProviders: ServiceProviderRemoteDataSourceImpl(
        database: database,
        realtimeClient: realtime,
      ),
      sla: SlaRemoteDataSourceImpl(
        database: database,
        realtimeClient: realtime,
      ),
      users: UsersRemoteDataSourceImpl(
        database: database,
        realtimeClient: realtime,
      ),
      pause: PauseRemoteDataSourceImpl(database: database),
      observations: WorkOrderObservationsRemoteDataSourceImpl(
        database: database,
      ),
      workOrders: WorkOrdersRemoteDataSourceImpl(database: database),
      workOrdersRealtime: WorkOrdersRealtimeRemoteDataSourceImpl(
        realtimeClient: realtime,
      ),
    );
  }

  final AccessLogsRemoteDataSource accessLogs;
  final AssetsRemoteDataSource assets;
  final AttachmentsRemoteDataSource attachments;
  final AuthRemoteDataSource auth;
  final CategoriesRemoteDataSource categories;
  final ChecklistsRemoteDataSource checklists;
  final CompanyRemoteDataSource company;
  final ConfigurationsRemoteDataSource configurations;
  final LocationsRemoteDataSource locations;
  final NotificationsRemoteDataSource notifications;
  final SectorsRemoteDataSource sectors;
  final ServiceProviderRemoteDataSource serviceProviders;
  final SlaRemoteDataSource sla;
  final UsersRemoteDataSource users;
  final PauseRemoteDataSource pause;
  final WorkOrderObservationsRemoteDataSource observations;
  final WorkOrdersRemoteDataSource workOrders;
  final WorkOrdersRealtimeRemoteDataSource workOrdersRealtime;
}
