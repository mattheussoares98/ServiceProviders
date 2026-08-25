import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/repositories/assets_repository.dart';

@LazySingleton()
class WatchAssetsRealtimeUseCase {
  const WatchAssetsRealtimeUseCase({
    required AssetsRepository assetsRepository,
  }) : _assetsRepository = assetsRepository;

  final AssetsRepository _assetsRepository;

  Stream<RealtimeEvent<AssetEntity>> call({String? companyId}) =>
      _assetsRepository.watchAssetsRealtime(companyId: companyId);
}
