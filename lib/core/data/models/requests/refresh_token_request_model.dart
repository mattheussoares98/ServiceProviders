class RefreshTokenRequestModel {
  const RefreshTokenRequestModel({required this.refreshToken});
  final String refreshToken;

  Map<String, String> toJson() => {'refresh': refreshToken};
}
