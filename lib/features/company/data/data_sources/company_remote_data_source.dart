import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:o_jogo_da_obra/core/clients/remote/supabase/database/supabase_filter.dart';
import 'package:o_jogo_da_obra/core/data/handlers/supabase_handler.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_parameter_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';

abstract interface class CompanyRemoteDataSource {
  FutureData<CompanyModel> createCompany(CompanyRequestModel request);
  FutureData<CompanyModel> getCompany(String id);
  FutureData<CompanyParameterModel> getCompanyParameters(String companyId);
  FutureData<CompanyParameterModel> saveCompanyParameters(
    CompanyParameterRequestModel request,
  );
}

@LazySingleton(as: CompanyRemoteDataSource)
final class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  const CompanyRemoteDataSourceImpl({required SupabaseDatabaseClient database})
    : _database = database;

  final SupabaseDatabaseClient _database;

  @override
  FutureData<CompanyModel> createCompany(CompanyRequestModel request) =>
      SupabaseHandler.call(() async {
        final rows = await _database.insert(
          table: 'companies',
          values: request.toJson(),
        );
        return CompanyModel.fromJson(rows.first);
      });

  @override
  FutureData<CompanyModel> getCompany(String id) =>
      SupabaseHandler.call(() async {
        final company = await _database.selectOne(
          table: 'companies',
          filters: [SupabaseFilter.eq('id', id)],
        );

        if (company == null) {
          throw Exception('Empresa não encontrada'.hardcoded);
        }
        return CompanyModel.fromJson(company);
      });

  @override
  FutureData<CompanyParameterModel> getCompanyParameters(String companyId) =>
      SupabaseHandler.call(() async {
        final params = await _database.selectOne(
          table: 'company_parameters',
          filters: [
            SupabaseFilter.eq('company_id', companyId),
            SupabaseFilter.isFilter('deleted_at', null),
          ],
        );

        if (params == null) {
          throw Exception('Parâmetros da empresa não encontrados'.hardcoded);
        }
        return CompanyParameterModel.fromJson(params);
      });

  @override
  FutureData<CompanyParameterModel> saveCompanyParameters(
    CompanyParameterRequestModel request,
  ) => SupabaseHandler.call(() async {
    final rows = await _database.upsert(
      table: 'company_parameters',
      values: request.toJson(),
      onConflict: 'company_id',
    );
    return CompanyParameterModel.fromJson(rows.first);
  });
}
