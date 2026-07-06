import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/error_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';

abstract interface class CompanyRemoteDataSource {
  FutureData<CompanyModel> createCompany(CompanyRequestModel request);
  FutureData<CompanyModel> getCompany(String id);
}

@LazySingleton(as: CompanyRemoteDataSource)
final class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  const CompanyRemoteDataSourceImpl({required SupabaseDatabaseClient database})
    : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureData<CompanyModel> createCompany(CompanyRequestModel request) =>
      ErrorHandler.execute(() async {
        final rows = await _database.insert(
          table: 'companies',
          values: request.toJson(),
        );
        return SuccessState(data: CompanyModel.fromJson(rows.first));
      });

  @override
  FutureData<CompanyModel> getCompany(String id) {
    return ErrorHandler.execute(() async {
      final company = await _database.selectOne(
        table: 'companies',
        filters: [SupabaseFilter.eq('id', id)],
      );

      if (company == null) {
        return FailureState(message: 'Empresa não encontrada'.hardcoded);
      }
      return SuccessState(data: CompanyModel.fromJson(company));
    });
  }
}
