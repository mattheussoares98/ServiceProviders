import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/realtime_payload_mapper.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/realtime/supabase_realtime_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SectorsRemoteDataSource {
  FutureList<SectorModel> getSectors(String companyId);
  FutureData<SectorModel> createSector(SectorModel request);
  FutureData<SectorModel> updateSector(SectorModel request);
  FutureVoid deleteSector(String id);
  Stream<RealtimeEvent<SectorModel>> watchSectorsRealtime({String? companyId});
}

@LazySingleton(as: SectorsRemoteDataSource)
final class SectorsRemoteDataSourceImpl implements SectorsRemoteDataSource {
  const SectorsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
    required SupabaseRealtimeClient realtimeClient,
  }) : _database = database,
       _realtimeClient = realtimeClient;

  final SupabaseDatabaseClient _database;
  final SupabaseRealtimeClient _realtimeClient;

  @override
  FutureList<SectorModel> getSectors(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'sectors',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(SectorModel.fromJson).toList();
      });

  @override
  FutureData<SectorModel> createSector(SectorModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'sectors',
          values: request.toJson(),
        );
        return SectorModel.fromJson(response.first);
      });

  @override
  FutureData<SectorModel> updateSector(SectorModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.update(
          table: 'sectors',
          values: request.toJson(),
          filters: [SupabaseFilter.eq('id', request.id)],
        );
        return SectorModel.fromJson(response.first);
      });

  @override
  FutureVoid deleteSector(String id) => SupabaseHandler.voidCall(() async {
    await _database.update(
      table: 'sectors',
      values: {'deleted_at': DateTime.now().toIsoUtcString()},
      filters: [SupabaseFilter.eq('id', id)],
    );
  });

  @override
  Stream<RealtimeEvent<SectorModel>> watchSectorsRealtime({String? companyId}) {
    final filter = companyId != null && companyId.isNotEmpty
        ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'company_id',
            value: companyId,
          )
        : null;

    return _realtimeClient
        .streamTableChanges(table: 'sectors', filter: filter)
        .map(
          (payload) => RealtimePayloadMapper.map(payload, SectorModel.fromJson),
        );
  }
}
