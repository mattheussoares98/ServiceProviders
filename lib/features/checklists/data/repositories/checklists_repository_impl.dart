import 'package:clean_architecture/core/clients/remote/internet_client.dart';
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_local_data_source.dart';
import 'package:clean_architecture/features/checklists/data/data_sources/checklists_remote_data_source.dart';
import 'package:clean_architecture/features/checklists/domain/repositories/checklists_repository.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: ChecklistsRepository)
final class ChecklistsRepositoryImpl implements ChecklistsRepository {
  ChecklistsRepositoryImpl({
    required InternetClient internet,
    required ChecklistsRemoteDataSource remoteDataSource,
    required ChecklistsLocalDataSource localDataSource,
  })  : _internet = internet,
        _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final InternetClient _internet;
  final ChecklistsRemoteDataSource _remoteDataSource;
  final ChecklistsLocalDataSource _localDataSource;
}
