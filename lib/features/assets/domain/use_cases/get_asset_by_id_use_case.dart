import 'package:clean_architecture/core/domain/use_cases/use_case.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/repositories/assets_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class GetAssetByIdUseCase implements UseCase<AssetEntity, String> {
  GetAssetByIdUseCase({required AssetsRepository assetsRepository})
      : _assetsRepository = assetsRepository;

  final AssetsRepository _assetsRepository;

  @override
  FutureData<AssetEntity> call(String request) =>
      _assetsRepository.getAssetById(request);
}
