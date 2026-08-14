import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/clients/remote/internet_client.dart';
import 'package:o_jogo_da_obra/core/data/handlers/repository_handler.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_local_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/data_sources/pause_remote_data_source.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_reason_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/data/models/responses/pause_request_model.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/repositories/pause_repository.dart';

@LazySingleton(as: PauseRepository)
final class PauseRepositoryImpl implements PauseRepository {
  const PauseRepositoryImpl({
    required InternetClient internet,
    required PauseRemoteDataSource remoteDataSource,
    required PauseLocalDataSource localDataSource,
  }) : _internet = internet,
       _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final InternetClient _internet;
  final PauseRemoteDataSource _remoteDataSource;
  final PauseLocalDataSource _localDataSource;

  @override
  FutureList<PauseReasonEntity> getPauseReasons(String companyId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        PauseReasonModel,
        PauseReasonEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getPauseReasons(companyId),
        remoteCallback: () => _remoteDataSource.getPauseReasons(companyId),
        onRemoteSuccess: (list) async {
          await Future.wait(
            list.map(_localDataSource.savePauseReason).toList(),
          );
          return const SuccessState(data: true);
        },
      );

  @override
  FutureList<PauseRequestEntity> getPauseRequests(String workOrderId) =>
      RepositoryHandler.fetchWithFallbackAndMapList<
        PauseRequestModel,
        PauseRequestEntity
      >(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.getPauseRequests(workOrderId),
        remoteCallback: () => _remoteDataSource.getPauseRequests(workOrderId),
        onRemoteSuccess: (list) async {
          await Future.wait(
            list.map(_localDataSource.savePauseRequest).toList(),
          );
          return const SuccessState(data: true);
        },
      );

  @override
  FutureBool requestPause(PauseRequestEntity pauseRequest) =>
      RepositoryHandler.fetchWithFallback<bool>(
        isInternetConnected: _internet.isConnected,
        localCallback: () => _localDataSource.savePauseRequest(
          PauseRequestModel.fromEntity(pauseRequest),
        ),
        remoteCallback: () async {
          final result = await _remoteDataSource.requestPause(
            PauseRequestModel.fromEntity(pauseRequest),
          );
          if (result is SuccessState<bool> && result.data == true) {
            await _localDataSource.savePauseRequest(
              PauseRequestModel.fromEntity(pauseRequest),
            );
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
  FutureBool reviewPause({
    required String id,
    required PauseRequestStatus status,
    String? reviewObservation,
    required String reviewedById,
    String? reasonId,
    PauseResponsibility? responsibility,
  }) => RepositoryHandler.fetchWithFallback<bool>(
    isInternetConnected: _internet.isConnected,
    localCallback: () => _localDataSource.reviewPause(
      id: id,
      status: status.value,
      reviewObservation: reviewObservation,
      reviewedById: reviewedById,
      reasonId: reasonId,
      responsibility: responsibility?.value,
    ),
    remoteCallback: () async {
      final result = await _remoteDataSource.reviewPause(
        id: id,
        status: status.value,
        reviewObservation: reviewObservation,
        reviewedById: reviewedById,
        reasonId: reasonId,
        responsibility: responsibility?.value,
      );
      if (result is SuccessState<bool> && result.data == true) {
        await _localDataSource.reviewPause(
          id: id,
          status: status.value,
          reviewObservation: reviewObservation,
          reviewedById: reviewedById,
          reasonId: reasonId,
          responsibility: responsibility?.value,
        );
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
  FutureBool cancelPause({
    required String id,
    required DateTime resumedAt,
    required String resumedById,
  }) => RepositoryHandler.fetchWithFallback<bool>(
    isInternetConnected: _internet.isConnected,
    localCallback: () => _localDataSource.cancelPause(
      id: id,
      resumedAt: resumedAt,
      resumedById: resumedById,
    ),
    remoteCallback: () async {
      final result = await _remoteDataSource.cancelPause(
        id: id,
        resumedAt: resumedAt,
        resumedById: resumedById,
      );
      if (result is SuccessState<bool> && result.data == true) {
        await _localDataSource.cancelPause(
          id: id,
          resumedAt: resumedAt,
          resumedById: resumedById,
        );
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
}
