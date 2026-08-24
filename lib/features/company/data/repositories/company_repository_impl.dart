import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_local_data_source.dart';
import 'package:o_jogo_da_obra/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_parameter_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/requests/company_request_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_model.dart';
import 'package:o_jogo_da_obra/features/company/data/models/responses/company_parameter_model.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/entities/company_parameter_entity.dart';
import 'package:o_jogo_da_obra/features/company/domain/repositories/company_repository.dart';

@LazySingleton(as: CompanyRepository)
final class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl({
    required InternetClient internet,
    required CompanyRemoteDataSource remoteDataSource,
    required CompanyLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final CompanyRemoteDataSource _remoteDataSource;
  final CompanyLocalDataSource _localDataSource;

  CompanyEntity? _cachedCompany;

  @override
  FutureData<CompanyEntity> createCompany(CompanyEntity company) async {
    final result =
        await RepositoryHandler.fetchWithFallbackAndMap<
          CompanyModel,
          CompanyEntity
        >(
          isInternetConnected: _internet.isConnected,
          remoteCallback: () => _remoteDataSource.createCompany(
            CompanyRequestModel.fromEntity(company),
          ),
        );
    if (result is SuccessState<CompanyEntity>) {
      _cachedCompany = result.data;
    }
    return result;
  }

  @override
  FutureData<CompanyEntity> getCompany(
    String id, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedCompany != null && _cachedCompany!.id == id) {
      return SuccessState(data: _cachedCompany);
    }
    final result =
        await RepositoryHandler.fetchWithFallbackAndMap<
          CompanyModel,
          CompanyEntity
        >(
          isInternetConnected: _internet.isConnected,
          remoteCallback: () => _remoteDataSource.getCompany(id),
          localCallback: () => _localDataSource.getCompany(id),
          onRemoteSuccess: _localDataSource.saveCompany,
        );
    if (result is SuccessState<CompanyEntity>) {
      _cachedCompany = result.data;
    }
    return result;
  }

  @override
  FutureData<CompanyParameterEntity> getCompanyParameters(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMap<
        CompanyParameterModel,
        CompanyParameterEntity
      >(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getCompanyParameters(companyId),
        localCallback: () => _localDataSource.getCompanyParameters(companyId),
        onRemoteSuccess: _localDataSource.saveCompanyParameters,
      );

  @override
  FutureBool saveCompany(CompanyEntity company) =>
      _localDataSource.saveCompany(CompanyModel.fromEntity(company));

  @override
  FutureBool saveCompanyParameters(CompanyParameterEntity parameters) async {
    final model = CompanyParameterModel.fromEntity(parameters);
    final requestModel = CompanyParameterRequestModel.fromEntity(parameters);
    if (_internet.isConnected) {
      final remoteResult = await _remoteDataSource.saveCompanyParameters(
        requestModel,
      );
      if (remoteResult is FailureState<CompanyParameterModel>) {
        return FailureState(
          message: remoteResult.message,
          error: remoteResult.error,
        );
      }
    }
    return _localDataSource.saveCompanyParameters(model);
  }
}

