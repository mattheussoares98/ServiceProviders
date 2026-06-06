import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_local_data_source.dart';
import 'package:clean_architecture/features/company/data/data_sources/company_remote_data_source.dart';
import 'package:clean_architecture/features/company/domain/repositories/company_repository.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: CompanyRepository)
final class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl({
    required InternetClient internet,
    required CompanyRemoteDataSource remoteDataSource,
    required CompanyLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final CompanyRemoteDataSource _remoteDataSource;
  final CompanyLocalDataSource _localDataSource;
}
