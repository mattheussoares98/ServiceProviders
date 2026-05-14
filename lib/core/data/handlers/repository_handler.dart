import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';

/// A utility for repository implementations to coordinate remote and local
/// data sources while mapping DTOs to domain models.
abstract final class RepositoryHandler {
  /// Fetches data with a network fallback strategy: tries [remoteCallback]
  /// if connected, otherwise falls back to [localCallback].
  static FutureData<T> fetchWithFallback<T>({
    required bool isInternetConnected,
    required FutureData<T> Function() remoteCallback,
    void Function(T data)? onRemoteSuccess,
    FutureData<T> Function()? localCallback,
  }) async {
    if (isInternetConnected) {
      final dataState = await remoteCallback();
      final data = dataState.data;

      // 1. Perform an action on successful remote fetch (e.g., cache the data)
      if (data != null && onRemoteSuccess != null) {
        onRemoteSuccess(data);
      }
      return dataState;
    }

    // 2. Fallback to local data source or return no internet error
    return localCallback?.call() ?? FailureState.noInternet();
  }

  /// Fetches a DTO from remote/local and maps it to a domain model.
  /// Expects the DTO type [T] to implement [DataConvertible].
  static FutureData<R>
  fetchWithFallbackAndMap<T extends DataConvertible<R>, R>({
    required bool isInternetConnected,
    required FutureData<T> Function() remoteCallback,
    void Function(T data)? onRemoteSuccess,
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
    void Function(List<T> data)? onRemoteSuccess,
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
}
