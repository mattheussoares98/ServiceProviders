import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/repositories/sectors_repository.dart';

@LazySingleton()
class WatchSectorsRealtimeUseCase {
  const WatchSectorsRealtimeUseCase({
    required SectorsRepository sectorsRepository,
  }) : _sectorsRepository = sectorsRepository;

  final SectorsRepository _sectorsRepository;

  Stream<RealtimeEvent<SectorEntity>> call({String? companyId}) =>
      _sectorsRepository.watchSectorsRealtime(companyId: companyId);
}
