import 'package:clean_architecture/core/clients/remote/supabase/database/supabase_database_client.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/data/models/requests/company_request_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_model.dart';
import 'package:injectable/injectable.dart';

abstract interface class CompanyRemoteDataSource {
  FutureData<CompanyModel> createCompany(CompanyRequestModel request);
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
}
