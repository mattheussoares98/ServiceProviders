import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/use_cases/use_case.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/assets/domain/repositories/assets_repository.dart';

@LazySingleton()
class DeleteAssetUseCase implements UseCase<bool, String> {
  DeleteAssetUseCase({required AssetsRepository assetsRepository})
    : _assetsRepository = assetsRepository;

  final AssetsRepository _assetsRepository;

  @override
  FutureBool call(String request) => _assetsRepository.deleteAsset(request);
}
