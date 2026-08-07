import 'dart:developer';

import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/config/app_config.dart';
import 'package:o_jogo_da_obra/core/clients/local/local_storage_client.dart';
import 'package:o_jogo_da_obra/core/constants/api_endpoints.dart';
import 'package:o_jogo_da_obra/core/data/models/requests/refresh_token_request_model.dart';
import 'package:o_jogo_da_obra/core/data/models/responses/api_response.dart';
import 'package:o_jogo_da_obra/core/data/models/responses/refresh_token_response.dart';
import 'package:o_jogo_da_obra/core/domain/entities/user_data_entity.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/routing/helper/navigation_client.dart';
import 'package:o_jogo_da_obra/routing/routes.gr.dart';

part 'http_auth_interceptor.dart';
part 'multipart_client.dart';

/// Convenience methods to make an HTTP PATCH request.
abstract interface class HttpClient {
  void updateBaseUrl({required String baseUrl});

  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  Future<Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    MapDynamic? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  });
}

@module
abstract class HttpClientModule {
  @lazySingleton
  Dio get dio => Dio();

  @injectable
  bool get addInterceptors => false;
}

@LazySingleton(as: HttpClient)
final class HttpClientImpl implements HttpClient {
  HttpClientImpl({
    required Dio dio,
    required AppConfig appConfig,
    required HttpAuthInterceptor authInterceptor,
    required NavigationClient navigationClient,
    bool addInterceptors = false,
  }) : _dio = dio {
    _dio.options = BaseOptions(
      baseUrl: appConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    );

    if (addInterceptors) {
      /// Alice Configuration
      final alice = Alice(
        configuration: AliceConfiguration(
          navigatorKey: navigationClient.navigatorKey,
        ),
      );
      final aliceDioAdapter = AliceDioAdapter();
      alice.addAdapter(aliceDioAdapter);
      _dio.interceptors.addAll([authInterceptor, aliceDioAdapter]);
    }
  }
  final Dio _dio;

  @override
  void updateBaseUrl({required String baseUrl}) =>
      _dio.options.baseUrl = baseUrl;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.get(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
  );

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.post(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.put(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  @override
  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _dio.patch(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
  );

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    MapDynamic? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _dio.delete(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
    cancelToken: cancelToken,
  );

  @override
  Future<Response<dynamic>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    MapDynamic? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) => _dio.download(
    urlPath,
    savePath,
    onReceiveProgress: onReceiveProgress,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
    deleteOnError: deleteOnError,
    lengthHeader: lengthHeader,
    data: data,
    options: options,
  );
}
