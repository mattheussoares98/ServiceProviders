import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A normalized view of whatever went wrong, whichever layer produced it.
///
/// Two very different shapes have to end up here:
///
/// * A **raw client** call throws the real `PostgrestException` / `AuthException`
///   / `FunctionException`, so every field is available.
/// * A call through a **data source** does not throw at all — `SupabaseHandler`
///   routes it into `ErrorHandler.execute`, which flattens the exception into
///   `FailureState.error` as a plain string. [IntegrationError.fromState] recovers the code and
///   message from that string.
class IntegrationError {
  const IntegrationError({
    required this.type,
    this.code,
    this.message,
    this.details,
    this.hint,
    this.raw,
  });

  /// Recovers the error from a [FailureState] produced by a data source.
  ///
  /// `FailureState.statusCode` is not trusted as the sole source: `ErrorHandler`
  /// stores it as `exception.code?.toInt()`, which silently drops every
  /// non-numeric SQLSTATE — `P0001` (the code every `RAISE EXCEPTION` in this
  /// schema uses) becomes null. The code is therefore parsed back out of the
  /// flattened `error` string first, and the numeric field is only a fallback.
  factory IntegrationError.fromState(FailureState<Object?> state) {
    final raw = state.error;
    return IntegrationError(
      type: _typeIn(raw) ?? 'FailureState',
      code: _codeIn(raw) ?? state.statusCode?.toString(),
      message: state.message,
      raw: raw,
    );
  }

  /// Normalizes any failure shape into an [IntegrationError].
  factory IntegrationError.from(Object error) {
    if (error is FailureState<Object?>) return IntegrationError.fromState(error);
    return fromException(error) ??
        IntegrationError(
          type: error.runtimeType.toString(),
          message: error.toString(),
          raw: error.toString(),
        );
  }


  /// Runtime type name of the originating exception, or `FailureState`.
  final String type;

  /// Postgres SQLSTATE (`42501` RLS denial, `23503` FK, `23505` unique,
  /// `23514` check, `23502` not-null, `42703` undefined column, `P0001` from a
  /// `RAISE EXCEPTION`) or an HTTP status for edge functions.
  final String? code;
  final String? message;
  final String? details;
  final String? hint;
  final String? raw;

  /// Builds from a thrown exception. Returns null for a non-Supabase error,
  /// which the caller records as a plain assertion failure instead.
  static IntegrationError? fromException(Object error) {
    switch (error) {
      case final PostgrestException e:
        return IntegrationError(
          type: 'PostgrestException',
          code: e.code,
          message: e.message,
          details: e.details?.toString(),
          hint: e.hint,
          raw: e.toString(),
        );
      case final AuthException e:
        return IntegrationError(
          type: 'AuthException',
          code: e.statusCode,
          message: e.message,
          raw: e.toString(),
        );
      case final FunctionException e:
        return IntegrationError(
          type: 'FunctionException',
          code: e.status.toString(),
          details: e.details?.toString(),
          message: e.reasonPhrase,
          raw: e.toString(),
        );
      default:
        return null;
    }
  }

  static final _codePattern = RegExp(r'code:\s*([A-Za-z0-9]+)');
  static final _typePattern = RegExp('^([A-Za-z]+Exception)');

  static String? _codeIn(String? raw) {
    if (raw == null) return null;
    final match = _codePattern.firstMatch(raw);
    final code = match?.group(1);
    return code == 'null' ? null : code;
  }

  static String? _typeIn(String? raw) =>
      raw == null ? null : _typePattern.firstMatch(raw)?.group(1);

  Map<String, Object?> toJson() => {
    'type': type,
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    if (details != null) 'details': details,
    if (hint != null) 'hint': hint,
    if (raw != null) 'raw': raw,
  };

  @override
  String toString() => '$type(code: $code) ${message ?? ''}'.trim();
}
