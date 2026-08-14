import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';

abstract interface class PauseRemoteDataSource {
  FutureList<PauseReasonModel> getPauseReasons(String companyId);
  FutureList<PauseRequestModel> getPauseRequests(String workOrderId);
  FutureBool requestPause(PauseRequestModel pauseRequest);
  FutureBool reviewPause({
    required String id,
    required String status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
    String? responsibility,
  });
  FutureBool cancelPause({
    required String id,
    required DateTime resumedAt,
    required String resumedById,
  });
}

@LazySingleton(as: PauseRemoteDataSource)
final class PauseRemoteDataSourceImpl implements PauseRemoteDataSource {
  const PauseRemoteDataSourceImpl({required SupabaseDatabaseClient database})
    : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<PauseReasonModel> getPauseReasons(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'pause_reasons',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(PauseReasonModel.fromJson).toList();
      });

  @override
  FutureList<PauseRequestModel> getPauseRequests(String workOrderId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'work_order_pause_requests',
          filters: [SupabaseFilter.eq('work_order_id', workOrderId)],
        );
        return response.map(PauseRequestModel.fromJson).toList();
      });

  @override
  FutureBool requestPause(PauseRequestModel pauseRequest) =>
      SupabaseHandler.call(() async {
        await _database.insert(
          table: 'work_order_pause_requests',
          values: pauseRequest.toJson(),
        );
        return true;
      });

  @override
  FutureBool reviewPause({
    required String id,
    required String status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
    String? responsibility,
  }) => SupabaseHandler.call(() async {
    final MapDynamic values = {
      'status': status,
      'reviewed_by_id': reviewedById,
      'updated_at': DateTime.now().toIsoUtcString(),
      'review_observation': ?reviewObservation,
      'reason_id': ?reasonId,
      'responsibility': ?responsibility,
    };
    await _database.update(
      table: 'work_order_pause_requests',
      values: values,
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });

  @override
  FutureBool cancelPause({
    required String id,
    required DateTime resumedAt,
    required String resumedById,
  }) => SupabaseHandler.call(() async {
    final MapDynamic values = {
      'resumed_at': resumedAt.toIsoUtcString(),
      'resumed_by_id': resumedById,
      'updated_at': DateTime.now().toIsoUtcString(),
    };
    await _database.update(
      table: 'work_order_pause_requests',
      values: values,
      filters: [SupabaseFilter.eq('id', id)],
    );
    return true;
  });
}
