import 'dart:developer' show log;

import 'package:clean_architecture/core/data/states/data_state.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class ErrorHandler {
  /// Run an async callback and log any exceptions (does not rethrow).
  ///
  /// Use this to execute `Future`-returning code where errors should be
  /// logged for diagnostics but not propagated.
  static Future<void> executeSafe(Future<void> Function() callBack) async {
    try {
      await callBack();
    } catch (error, stackTrace) {
      _debugError(error, stackTrace);
    }
  }

  /// Run an async callback that returns `T`, logging exceptions.
  ///
  /// On error this returns the provided `valueOnError` fallback.
  static Future<T> executeSafeReturn<T>(
    Future<T> Function() callBack, {
    required T valueOnError,
  }) async {
    try {
      return await callBack();
    } catch (error, stackTrace) {
      _debugError(error, stackTrace);
      return valueOnError;
    }
  }

  /// Run a synchronous callback and log any exceptions (no rethrow).
  static void executeSafeSync(void Function() callBack) {
    try {
      callBack();
    } catch (error, stackTrace) {
      _debugError(error, stackTrace);
    }
  }

  /// Run a synchronous callback that returns `T`, logging exceptions.
  ///
  /// On error this returns the provided `valueOnError` fallback.
  static T executeSafeReturnSync<T>(
    T Function() callBack, {
    required T valueOnError,
  }) {
    try {
      return callBack();
    } catch (error, stackTrace) {
      _debugError(error, stackTrace);
      return valueOnError;
    }
  }

  /// Execute a callback that returns a `FutureData<T>` and convert
  /// thrown exceptions into appropriate `FailureState<T>` instances.
  static FutureData<T> execute<T>(FutureData<T> Function() callBack) async {
    try {
      return await callBack();
    } on DioException catch (exception, stackTrace) {
      _debugError('Http Response: ${exception.response}');
      _debugError(exception, stackTrace);
      return _handleDioException<T>(exception);
    } on AuthException catch (exception, stackTrace) {
      _debugError(exception, stackTrace);
      final statusStr = exception.statusCode;
      final statusCode = statusStr != null ? int.tryParse(statusStr) : null;
      return FailureState<T>(
        message: exception.message,
        error: exception.toString(),
        statusCode: statusCode,
      );
    } catch (error, stackTrace) {
      _debugError(error, stackTrace);
      return FailureState<T>(error: error.toString());
    }
  }

  /// Map a `DioException` to a `FailureState<T>` with an appropriate
  /// user-facing message and error metadata.
  static FailureState<T> _handleDioException<T>(DioException exception) {
    final errorType = exception.type;
    final response = exception.response;
    final statusCode = response?.statusCode ?? 0;

    /// If the server response contains error status codes
    if (errorType == .badResponse && response != null) {
      String? errorMessage, error;
      if (response.data case final MapDynamic responseBody) {
        errorMessage = responseBody['message'] as String?;
        error = 'Response: $responseBody';
      }

      if (statusCode >= 400 && statusCode < 500) {
        return FailureState.badRequest(
          message: errorMessage,
          error: error,
          statusCode: statusCode,
          response: response,
        );
      } else if (statusCode >= 500) {
        return FailureState.serverError(
          message: errorMessage,
          error: error,
          statusCode: statusCode,
          response: response,
        );
      }
    }

    return FailureState(
      message: _dioErrorMessages[errorType.name],
      error: exception.toString(),
      statusCode: response?.statusCode,
      response: response,
    );
  }

  /// Internal debug logger used to print caught exceptions in debug mode.
  static void _debugError(Object? error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      log(
        '<--------- Caught Exception ---------->',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static const _dioErrorMessages = {
    'connectionError': 'Connection error, host lookup failed.',
    'cancel': 'Request was cancelled',
    'receiveTimeout': 'Receive timeout in connection. $kCheckInternet',
    'sendTimeout': 'Send timeout in connection. $kCheckInternet',
    'connectionTimeout': 'Connection timeout. $kCheckInternet',
    'badCertificate': 'Bad certificate. $kCustomerSupport',
  };
}
