import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event.dart';
import 'package:o_jogo_da_obra/core/domain/entities/realtime_event_type.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

/// A utility for repository implementations to coordinate remote and local
/// data sources while mapping DTOs to domain models.
abstract final class RepositoryHandler {
  /// Fetches data with a network fallback strategy: tries [remoteCallback]
  /// if connected, otherwise falls back to [localCallback].
  static FutureData<T> fetchWithFallback<T>({
    required bool isInternetConnected,
    required FutureData<T> Function() remoteCallback,
    FutureData<Object?> Function(T data)? onRemoteSuccess,
    FutureData<T> Function()? localCallback,
  }) async {
    if (isInternetConnected) {
      final dataState = await remoteCallback();
      final data = dataState.data;

      // 1. Perform an action on successful remote fetch (e.g., cache the data)
      if (data != null && onRemoteSuccess != null) {
        final sideEffectState = await onRemoteSuccess(data);
        if (sideEffectState is FailureState<Object?>) {
          return FailureState<T>(
            message: sideEffectState.message,
            error: sideEffectState.error,
            statusCode: sideEffectState.statusCode,
            response: sideEffectState.response,
          );
        }
      }
      return dataState;
    }

    // 2. Fallback to local data source or return no internet error
    return await localCallback?.call() ?? FailureState.noInternet();
  }

  /// Executes a mutation with remote-first strategy and optional local mirroring.
  ///
  /// - If [isInternetConnected] is false, invokes [localCallback] if provided,
  ///   or returns [FailureState.noInternet] for online-only mutations.
  /// - If online, executes [remoteCallback]. Any remote [FailureState] is returned immediately.
  /// - If remote succeeds, calls [onRemoteSuccess] if provided. If [onRemoteSuccess]
  ///   returns a [FailureState], that failure is surfaced.
  /// - Returns [SuccessState(data: true)] on complete success.
  static FutureData<bool> executeMutation<T>({
    required bool isInternetConnected,
    required FutureData<T> Function() remoteCallback,
    FutureData<Object?> Function(T data)? onRemoteSuccess,
    FutureData<bool> Function()? localCallback,
  }) async {
    if (!isInternetConnected) {
      return await localCallback?.call() ?? FailureState.noInternet();
    }

    final remoteResult = await remoteCallback();
    if (remoteResult is FailureState) {
      return FailureState<bool>(
        message: remoteResult.message,
        error: remoteResult.error,
        statusCode: remoteResult.statusCode,
        response: remoteResult.response,
      );
    }

    if (onRemoteSuccess != null) {
      final data = remoteResult.data;
      if (data != null || null is T) {
        final sideEffectState = await onRemoteSuccess(data as T);
        if (sideEffectState is FailureState<Object?>) {
          return FailureState<bool>(
            message: sideEffectState.message,
            error: sideEffectState.error,
            statusCode: sideEffectState.statusCode,
            response: sideEffectState.response,
          );
        }
      }
    }

    return const SuccessState(data: true);
  }

  /// Fetches a DTO from remote/local and maps it to a domain model.
  /// Expects the DTO type [T] to implement [DataConvertible].
  static FutureData<R>
  fetchWithFallbackAndMap<T extends DataConvertible<R>, R>({
    required bool isInternetConnected,
    required FutureData<T> Function() remoteCallback,
    FutureData<Object?> Function(T data)? onRemoteSuccess,
    FutureData<T> Function()? localCallback,
  }) async {
    final dtoState = await fetchWithFallback(
      isInternetConnected: isInternetConnected,
      remoteCallback: remoteCallback,
      onRemoteSuccess: onRemoteSuccess,
      localCallback: localCallback,
    );

    // Transform the DataState containing the DTO (T) to Domain Model (R)
    return dtoState.mapData((dto) => dto.toEntity());
  }

  /// Fetches a list of DTOs from remote/local and maps them to domain models.
  /// Expects [T] to implement [DataConvertible].
  static FutureList<R>
  fetchWithFallbackAndMapList<T extends DataConvertible<R>, R>({
    required bool isInternetConnected,
    required FutureList<T> Function() remoteCallback,
    FutureData<Object?> Function(List<T> data)? onRemoteSuccess,
    FutureData<List<T>> Function()? localCallback,
  }) async {
    final dtoState = await fetchWithFallback(
      isInternetConnected: isInternetConnected,
      remoteCallback: remoteCallback,
      onRemoteSuccess: onRemoteSuccess,
      localCallback: localCallback,
    );

    return dtoState.mapData((list) => list.map((e) => e.toEntity()).toList());
  }

  /// Fetches a DTO from local storage and maps it to a domain model.
  static FutureData<R> fetchFromLocalAndMap<T extends DataConvertible<R>, R>({
    required FutureData<T> Function() localCallback,
  }) async {
    // Error handling is expected to be implemented within the localCallback.
    final dtoState = await localCallback();
    return dtoState.mapData((dto) => dto.toEntity());
  }

  /// Fetches a list of DTOs from local storage and maps them to domain models.
  static FutureList<R> fetchFromLocalAndMapList<
    T extends DataConvertible<R>,
    R
  >({required FutureList<T> Function() localCallback}) async {
    final dtoState = await localCallback();
    return dtoState.mapData((list) => list.map((e) => e.toEntity()).toList());
  }

  /// Coordinates a remote realtime stream with local persistence and maps
  /// remote DTOs/models to domain entities.
  static Stream<RealtimeEvent<R>> syncRealtimeStream<T, R>({
    required Stream<RealtimeEvent<T>> stream,
    Future<void> Function(T model)? saveLocal,
    Future<void> Function(String id)? deleteLocal,
    bool Function(T model)? isDeleted,
    R Function(T model)? toEntity,
  }) {
    return stream.asyncMap((event) async {
      final model = event.entity;

      if (model != null &&
          (event.eventType == RealtimeEventType.insert ||
              event.eventType == RealtimeEventType.update)) {
        final deleted = isDeleted?.call(model) ?? false;
        if (deleted) {
          await deleteLocal?.call(event.id);
        } else {
          await saveLocal?.call(model);
        }
      } else if (event.eventType == RealtimeEventType.delete &&
          event.id.isNotEmpty) {
        await deleteLocal?.call(event.id);
      }

      final entity = model != null
          ? (toEntity != null
                ? toEntity(model)
                : (model is DataConvertible<R>
                      ? (model as DataConvertible<R>).toEntity()
                      : (model as R)))
          : null;

      return RealtimeEvent<R>(
        eventType: event.eventType,
        id: event.id,
        companyId: event.companyId,
        entity: entity,
      );
    });
  }
}
