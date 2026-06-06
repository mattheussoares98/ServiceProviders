import 'package:clean_architecture/core/utils/type_defs.dart';

class RefreshTokenResponse {
  const RefreshTokenResponse({required this.accessToken});

  factory RefreshTokenResponse.fromJson(MapDynamic json) =>
      RefreshTokenResponse(accessToken: json['access'] as String);
  final String accessToken;
}
