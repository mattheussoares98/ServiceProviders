import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/work_order_observation_model.dart';

abstract interface class WorkOrderObservationsRemoteDataSource {
  FutureList<WorkOrderObservationModel> getObservations(String workOrderId);
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
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<WorkOrderObservationModel> getObservations(String workOrderId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'work_order_observations',
          columns: '*, author:user_profiles!author_id(name)',
          filters: [
            SupabaseFilter.eq('work_order_id', workOrderId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(WorkOrderObservationModel.fromJson).toList();
      });

  @override
  FutureData<WorkOrderObservationModel> createObservation(
    WorkOrderObservationModel observation,
  ) => SupabaseHandler.call(() async {
    final response = await _database.insert(
      table: 'work_order_observations',
      values: observation.toJson(),
      columns: '*, author:user_profiles!author_id(name)',
    );
    return WorkOrderObservationModel.fromJson(response.first);
  });

  @override
  FutureBool deleteObservation(String observationId) =>
      SupabaseHandler.call(() async {
        await _database.update(
          table: 'work_order_observations',
          values: {'deleted_at': DateTime.now().toIso8601String()},
          filters: [SupabaseFilter.eq('id', observationId)],
        );
        return true;
      });
}
