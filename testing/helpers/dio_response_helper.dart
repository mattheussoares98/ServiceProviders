import 'package:dio/dio.dart';
import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

Response<dynamic> getResponse({
  dynamic data,
  String responseDataKey = 'data',
  String? message,
  int? statusCode,
  RequestOptions? requestOptions,
  bool isStandardResponse = true,
}) => Response(
  data: isStandardResponse ? {responseDataKey: data, 'message': message} : data,
  requestOptions: requestOptions ?? RequestOptions(),
  statusCode: statusCode,
);

DioException getDioException({
  dynamic data,
  String responseDataKey = 'data',
  String? message,
  int? statusCode,
  RequestOptions? requestOptions,
}) => DioException(
  requestOptions: requestOptions ?? RequestOptions(),
  response: getResponse(
    responseDataKey: responseDataKey,
    data: data,
    message: message,
    statusCode: statusCode,
  ),
  type: DioExceptionType.badResponse,
);

class FakeDto implements DataConvertible<String> {
  FakeDto(this.value);
  final int value;

  @override
  String toEntity() => 'Mapped: $value';

  @override
  MapDynamic toJson() => {'value': value};
}
