import 'package:clean_architecture/core/clients/local/drift/app_database.dart';
import 'package:clean_architecture/core/data/handlers/error_handler.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/extensions/string_extension.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_parameter_response_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_response_model.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

abstract interface class CompanyLocalDataSource {
  FutureData<CompanyResponseModel> getCompany(String id);
  FutureData<CompanyParameterResponseModel> getCompanyParameters(
    String companyId,
  );
  FutureBool saveCompany(CompanyResponseModel company);
  FutureBool saveCompanyParameters(CompanyParameterResponseModel parameters);
}

@LazySingleton(as: CompanyLocalDataSource)
final class CompanyLocalDataSourceImpl implements CompanyLocalDataSource {
  const CompanyLocalDataSourceImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  FutureData<CompanyResponseModel> getCompany(String id) {
    return ErrorHandler.execute(() async {
      final company = await (_database.select(
        _database.companies,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (company != null) {
        return SuccessState(
          data: CompanyResponseModel(
            id: company.id,
            name: company.name,
            cnpj: company.cnpj,
            logoUrl: company.logoUrl,
            isActive: company.isActive,
            createdAt: company.createdAt,
            updatedAt: company.updatedAt,
            deletedAt: company.deletedAt,
          ),
        );
      }
      return FailureState<CompanyResponseModel>(
        message: 'Empresa não encontrada'.hardcoded,
      );
    });
  }

  @override
  FutureData<CompanyParameterResponseModel> getCompanyParameters(
    String companyId,
  ) {
    return ErrorHandler.execute(() async {
      final params = await (_database.select(
        _database.companyParameters,
      )..where((t) => t.companyId.equals(companyId))).getSingleOrNull();

      if (params != null) {
        return SuccessState(
          data: CompanyParameterResponseModel(
            id: params.id,
            companyId: params.companyId,
            maxOfflineDurationHours: params.maxOfflineDurationHours,
            maxOfflinePendingRequests: params.maxOfflinePendingRequests,
            createdAt: params.createdAt,
            updatedAt: params.updatedAt,
            deletedAt: params.deletedAt,
          ),
        );
      }
      return FailureState<CompanyParameterResponseModel>(
        message: 'Parâmetros da empresa não encontrados'.hardcoded,
      );
    });
  }

  @override
  FutureBool saveCompany(CompanyResponseModel company) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.companies)
          .insertOnConflictUpdate(
            CompaniesCompanion(
              id: Value(company.id),
              name: Value(company.name),
              cnpj: Value(company.cnpj),
              logoUrl: Value(company.logoUrl),
              isActive: Value(company.isActive),
              createdAt: Value(company.createdAt),
              updatedAt: Value(company.updatedAt),
              deletedAt: Value(company.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }

  @override
  FutureBool saveCompanyParameters(CompanyParameterResponseModel parameters) {
    return ErrorHandler.execute(() async {
      await _database
          .into(_database.companyParameters)
          .insertOnConflictUpdate(
            CompanyParametersCompanion(
              id: Value(parameters.id),
              companyId: Value(parameters.companyId),
              maxOfflineDurationHours: Value(
                parameters.maxOfflineDurationHours,
              ),
              maxOfflinePendingRequests: Value(
                parameters.maxOfflinePendingRequests,
              ),
              createdAt: Value(parameters.createdAt),
              updatedAt: Value(parameters.updatedAt),
              deletedAt: Value(parameters.deletedAt),
            ),
          );
      return const SuccessState(data: true);
    });
  }
}
