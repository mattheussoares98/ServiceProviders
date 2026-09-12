import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_local_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/data_sources/sectors_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/sectors/data/models/responses/sector_model.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/entities/sector_entity.dart';
import 'package:o_jogo_da_obra/features/sectors/domain/repositories/sectors_repository.dart';

@LazySingleton(as: SectorsRepository)
final class SectorsRepositoryImpl implements SectorsRepository {
  SectorsRepositoryImpl({
    required InternetClient internet,
    required SectorsRemoteDataSource remoteDataSource,
    required SectorsLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final SectorsRemoteDataSource _remoteDataSource;
  final SectorsLocalDataSource _localDataSource;

  @override
  FutureList<SectorEntity> getSectors(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<SectorModel, SectorEntity>(
        localCallback: () => _localDataSource.getSectors(companyId),
        isInternetConnected: _internet.isConnected,
        remoteCallback: () => _remoteDataSource.getSectors(companyId),
        onRemoteSuccess: _localDataSource.saveSectors,
      );

  @override
  FutureBool createSector(SectorEntity sector) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () =>
            _localDataSource.saveSector(SectorModel.fromEntity(sector)),
        remoteCallback: () async {
          final result = await _remoteDataSource.createSector(
            SectorModel.fromEntity(sector),
          );
          if (result is SuccessState<SectorModel>) {
            await _localDataSource.saveSector(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool updateSector(SectorEntity sector) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () =>
            _localDataSource.saveSector(SectorModel.fromEntity(sector)),
        remoteCallback: () async {
          final result = await _remoteDataSource.updateSector(
            SectorModel.fromEntity(sector),
          );
          if (result is SuccessState<SectorModel>) {
            await _localDataSource.saveSector(result.data!);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  FutureBool deleteSector(String id) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.deleteSector(id),
        remoteCallback: () async {
          final result = await _remoteDataSource.deleteSector(id);
          if (result is SuccessState<void>) {
            await _localDataSource.deleteSector(id);
            return const SuccessState(data: true);
          }
          return FailureState(
            message: result.message,
            error: result.error,
            statusCode: result.statusCode,
            response: result.response,
          );
        },
      );

  @override
  Stream<RealtimeEvent<SectorEntity>> watchSectorsRealtime({
    String? companyId,
  }) {
    return _remoteDataSource
        .watchSectorsRealtime(companyId: companyId)
        .asyncMap((event) async {
          if (event.entity != null &&
              (event.eventType == RealtimeEventType.insert ||
                  event.eventType == RealtimeEventType.update)) {
            if (event.entity!.deletedAt != null) {
              await _localDataSource.deleteSector(event.id);
            } else {
              await _localDataSource.saveSector(event.entity!);
            }
          } else if (event.eventType == RealtimeEventType.delete &&
              event.id.isNotEmpty) {
            await _localDataSource.deleteSector(event.id);
          }

          return RealtimeEvent<SectorEntity>(
            eventType: event.eventType,
            id: event.id,
            companyId: event.companyId,
            entity: event.entity?.toEntity(),
          );
        });
  }
}
