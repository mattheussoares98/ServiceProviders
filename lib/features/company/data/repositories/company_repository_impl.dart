import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/core/data/handlers/repository_handler.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_local_data_source.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:clean_architecture/features/company/data/models/requests/company_request_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_model.dart';
import 'package:clean_architecture/features/company/data/models/responses/company_parameter_model.dart';
import 'package:clean_architecture/features/company/domain/entities/company_entity.dart';
import 'package:clean_architecture/features/company/domain/entities/company_parameter_entity.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:injectable/injectable.dart';

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

  @override
  FutureData<CompanyEntity> createCompany(CompanyEntity company) =>
      RepositoryHandler.fetchWithFallbackAndMap<CompanyModel, CompanyEntity>(
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.createCompany(
          CompanyRequestModel.fromEntity(company),
        ),
      );

  @override
  FutureData<CompanyEntity> getCompany(String id) =>
      RepositoryHandler.fetchFromLocalAndMap<CompanyModel, CompanyEntity>(
        localCallback: () => _localDataSource.getCompany(id),
      );

  @override
  FutureData<CompanyParameterEntity> getCompanyParameters(String companyId) =>
      RepositoryHandler.fetchFromLocalAndMap<
        CompanyParameterModel,
        CompanyParameterEntity
      >(localCallback: () => _localDataSource.getCompanyParameters(companyId));

  @override
  FutureBool saveCompany(CompanyEntity company) =>
      _localDataSource.saveCompany(CompanyModel.fromEntity(company));

  @override
  FutureBool saveCompanyParameters(CompanyParameterEntity parameters) =>
      _localDataSource.saveCompanyParameters(
        CompanyParameterModel.fromEntity(parameters),
      );
}
