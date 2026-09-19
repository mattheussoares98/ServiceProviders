import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/data/models/responses/maintenance_plan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class MaintenancePlansRemoteDataSource {
  FutureList<MaintenancePlanModel> getPlans(String companyId);
  FutureData<MaintenancePlanModel> getPlanById(String id);
  FutureData<MaintenancePlanModel> createPlan(MaintenancePlanModel plan);
  FutureData<MaintenancePlanModel> updatePlan(MaintenancePlanModel plan);
  FutureVoid deletePlan(String id);
  Stream<RealtimeEvent<MaintenancePlanModel>> watchPlansRealtime({
    String? companyId,
  });
}

@LazySingleton(as: MaintenancePlansRemoteDataSource)
final class MaintenancePlansRemoteDataSourceImpl
    implements MaintenancePlansRemoteDataSource {
  const MaintenancePlansRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  @override
  FutureList<MaintenancePlanModel> getPlans(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'maintenance_plans',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(MaintenancePlanModel.fromJson).toList();
      });

  @override
  FutureData<MaintenancePlanModel> getPlanById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'maintenance_plans',
          filters: [
            SupabaseFilter.eq('id', id),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        if (response == null) {
          throw Exception('Plano de manutenção não encontrado');
        }
        return MaintenancePlanModel.fromJson(response);
      });

  @override
  FutureData<MaintenancePlanModel> createPlan(MaintenancePlanModel plan) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'maintenance_plans',
          values: plan.toJson(),
        );
        return MaintenancePlanModel.fromJson(response.first);
      });

  @override
  FutureData<MaintenancePlanModel> updatePlan(MaintenancePlanModel plan) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'maintenance_plans',
          values: plan.toJson(),
          filters: [SupabaseFilter.eq('id', plan.id)],
        );
        return MaintenancePlanModel.fromJson(response.first);
      });

  @override
  FutureVoid deletePlan(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'maintenance_plans',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<MaintenancePlanModel>> watchPlansRealtime({
    String? companyId,
  }) {
    return _realtimeClient
        .streamTableChanges(
          table: 'maintenance_plans',
          filter: companyId != null
              ? PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'company_id',
                  value: companyId,
                )
              : null,
        )
        .map(
          (payload) =>
              RealtimePayloadMapper.map(payload, MaintenancePlanModel.fromJson),
        );
  }
}
