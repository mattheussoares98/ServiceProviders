import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sla_policies/data/models/responses/sla_policy_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SlaRemoteDataSource {
  FutureList<SlaPolicyModel> getSlaPolicies(String companyId);
  FutureData<SlaPolicyModel> getSlaPolicyById(String id);
  FutureBool createSlaPolicy(SlaPolicyModel model);
  FutureBool updateSlaPolicy(SlaPolicyModel model);
  FutureVoid deleteSlaPolicy(String id);
  Stream<RealtimeEvent<SlaPolicyModel>> watchSlaPoliciesRealtime({
    String? companyId,
  });
}

@LazySingleton(as: SlaRemoteDataSource)
final class SlaRemoteDataSourceImpl implements SlaRemoteDataSource {
  const SlaRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  @override
  FutureList<SlaPolicyModel> getSlaPolicies(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'sla_policies',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(SlaPolicyModel.fromJson).toList();
      });

  @override
  FutureData<SlaPolicyModel> getSlaPolicyById(String id) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectOne(
          table: 'sla_policies',
          filters: [
            SupabaseFilter.eq('id', id),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        if (response == null) {
          throw _NotFoundException('Política de SLA não encontrada'.hardcoded);
        }
        return SlaPolicyModel.fromJson(response);
      });

  @override
  FutureBool createSlaPolicy(SlaPolicyModel model) =>
      SupabaseHandler.call(() async {
        await _database.insert(table: 'sla_policies', values: model.toJson());
        return true;
      });

  @override
  FutureBool updateSlaPolicy(SlaPolicyModel model) =>
      SupabaseHandler.call(() async {
        await _database.update(
          table: 'sla_policies',
          values: model.toJson(),
          filters: [SupabaseFilter.eq('id', model.id)],
        );
        return true;
      });

  @override
  FutureVoid deleteSlaPolicy(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'sla_policies',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<SlaPolicyModel>> watchSlaPoliciesRealtime({
    String? companyId,
  }) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(
          table: 'sla_policies',
          filter: filter,
        )
        .map((payload) => RealtimePayloadMapper.map(payload, SlaPolicyModel.fromJson));
  }
}

final class _NotFoundException implements Exception {
  const _NotFoundException(this.message);
  final String message;
  @override
  String toString() => message;
}
