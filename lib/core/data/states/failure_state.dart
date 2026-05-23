part of 'data_state.dart';

final String kCustomerSupport =
    'Entre em contato com o suporte técnico.'.hardcoded;
final String kErrorMessage = 'Erro inesperado. $kCustomerSupport'.hardcoded;
final String kCheckInternet =
    'Por favor, verifique sua internet e tente novamente.'.hardcoded;
final String kNoInternet =
    'Sem acesso à internet. Tente novamente mais tarde.'.hardcoded;

/// A failure data state when error occurs
final class FailureState<T> extends DataState<T> {
  FailureState({String? message, super.error, super.statusCode, super.response})
    : super(message: message ?? kErrorMessage, hasError: true);

  /// A failure data state when invalid data is provided to the server
  factory FailureState.badRequest({
    String? message,
    String? error,
    int? statusCode,
    Response<dynamic>? response,
  }) => FailureState(
    message: message ?? 'Requisição inválida. Tente novamente.'.hardcoded,
    error: error,
    statusCode: statusCode,
    response: response,
  );

  /// A failure data state when the user's token is expired
  factory FailureState.tokenExpired() => FailureState(
    message: 'Sua sessão expirou, faça login novamente.'.hardcoded,
  );

  /// A failure data state when the response of the server is invalid
  factory FailureState.badResponse({
    String? message,
    String? error,
    int? statusCode,
    Response<dynamic>? response,
  }) => FailureState(
    message: message ?? 'Erro no servidor. Tente novamente.'.hardcoded,
    error: error,
    statusCode: statusCode,
    response: response,
  );

  /// A failure data state when error occurs in the server
  factory FailureState.serverError({
    String? message,
    String? error,
    int? statusCode,
    Response<dynamic>? response,
  }) => FailureState(
    message: message ?? 'Erro no servidor. Tente novamente'.hardcoded,
    error: error,
    statusCode: statusCode,
    response: response,
  );

  /// A failure data state when there is no internet access
  factory FailureState.noInternet() =>
      FailureState(message: kNoInternet, error: kNoInternet);
}
