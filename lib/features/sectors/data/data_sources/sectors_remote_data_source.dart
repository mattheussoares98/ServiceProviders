import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_response_model.dart';

abstract interface class SectorsRemoteDataSource {
  FutureList<SectorResponseModel> getSectors(String companyId);
  FutureData<SectorResponseModel> createSector(SectorResponseModel request);
}

@LazySingleton(as: SectorsRemoteDataSource)
final class SectorsRemoteDataSourceImpl implements SectorsRemoteDataSource {
  const SectorsRemoteDataSourceImpl({
    required SupabaseDatabaseClient database,
  }) : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureList<SectorResponseModel> getSectors(String companyId) =>
      SupabaseHandler.call(() async {
        final response = await _database.selectList(
          table: 'sectors',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );
        return response.map(SectorResponseModel.fromJson).toList();
      });

  @override
  FutureData<SectorResponseModel> createSector(SectorResponseModel request) =>
      SupabaseHandler.call(() async {
        final response = await _database.insert(
          table: 'sectors',
          values: request.toJson(),
        );
        return SectorResponseModel.fromJson(response.first);
      });
}
