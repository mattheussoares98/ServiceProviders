import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class WorkOrderObservationsRemoteDataSource {
  FutureList<WorkOrderObservationModel> getObservations(String workOrderId);
  FutureList<WorkOrderObservationModel> getObservationsByWorkOrderIds(
    List<String> workOrderIds,
  );
  Stream<RealtimeEvent<WorkOrderObservationModel>> watchObservationsRealtime({
    required String workOrderId,
  });
  FutureData<WorkOrderObservationModel> createObservation(
    WorkOrderObservationModel observation,
  );
  FutureBool deleteObservation(String observationId);
}

@LazySingleton(as: WorkOrderObservationsRemoteDataSource)
final class WorkOrderObservationsRemoteDataSourceImpl
    implements WorkOrderObservationsRemoteDataSource {
  const WorkOrderObservationsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  /// Authorship points at one of two identity tables: user_profiles for
  /// internal employees, service_provider_profiles for provider mode.
  static const _columns =
      '*, author:user_profiles!author_id(name), '
      'provider_author:service_provider_profiles!author_provider_profile_id(name)';

  @override
  FutureList<WorkOrderObservationModel> getObservations(String workOrderId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'work_order_observations',
          columns: _columns,
          filters: [
            SupabaseFilter.eq('work_order_id', workOrderId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(WorkOrderObservationModel.fromJson).toList();
      });

  @override
  FutureList<WorkOrderObservationModel> getObservationsByWorkOrderIds(
    List<String> workOrderIds,
  ) => SupabaseHandler.call(() async {
    if (workOrderIds.isEmpty) {
      return const [];
    }
    final response = await _database.selectList(
      table: 'work_order_observations',
      columns: _columns,
      filters: [
        SupabaseFilter.inList('work_order_id', workOrderIds),
        SupabaseFilter.isFilter('deleted_at', null),
      ],
    );
    return response.map(WorkOrderObservationModel.fromJson).toList();
  });

  @override
  Stream<RealtimeEvent<WorkOrderObservationModel>> watchObservationsRealtime({
    required String workOrderId,
  }) {
    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'work_order_id',
      value: workOrderId,
    );

    return _realtimeClient
        .streamTableChanges(table: 'work_order_observations', filter: filter)
        .map(
          (payload) => RealtimePayloadMapper.map(
            payload,
            WorkOrderObservationModel.fromJson,
          ),
        );
  }

  @override
  FutureData<WorkOrderObservationModel> createObservation(
    WorkOrderObservationModel observation,
  ) => SupabaseHandler.call(() async {
    final response = await _database.insert(
      table: 'work_order_observations',
      values: observation.toJson(),
      columns: _columns,
    );
    return WorkOrderObservationModel.fromJson(response.first);
  });

  @override
  FutureBool deleteObservation(String observationId) =>
      SupabaseHandler.call(() async {
        await _database.update(
          table: 'work_order_observations',
          values: {'deleted_at': DateTime.now().toIsoUtcString()},
          filters: [SupabaseFilter.eq('id', observationId)],
        );
        return true;
      });
}
