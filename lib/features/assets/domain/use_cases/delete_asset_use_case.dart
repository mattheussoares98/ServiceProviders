import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class DeleteAssetUseCase implements UseCase<bool, String> {
  DeleteAssetUseCase({required AssetsRepository assetsRepository})
      : _assetsRepository = assetsRepository;

  final AssetsRepository _assetsRepository;

  @override
  FutureBool call(String request) => _assetsRepository.deleteAsset(request);
}
