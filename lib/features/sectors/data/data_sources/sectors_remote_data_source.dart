import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';

abstract interface class SectorsRemoteDataSource {
  FutureList<SectorModel> getSectors(String companyId);
  FutureData<SectorModel> createSector(SectorModel request);
  FutureData<SectorModel> updateSector(SectorModel request);
  FutureVoid deleteSector(String id);
}

@LazySingleton(as: SectorsRemoteDataSource)
final class SectorsRemoteDataSourceImpl implements SectorsRemoteDataSource {
  const SectorsRemoteDataSourceImpl({required SupabaseDatabaseClient database})
    : _database = database;

  final SupabaseDatabaseClient _database;

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
}
