import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/repositories/assets_repository.dart';

@LazySingleton()
class UpdateAssetUseCase implements UseCase<bool, AssetEntity> {
  UpdateAssetUseCase({required AssetsRepository assetsRepository})
    : _assetsRepository = assetsRepository;

  final AssetsRepository _assetsRepository;

  @override
  FutureBool call(AssetEntity request) =>
      _assetsRepository.updateAsset(request);
}
