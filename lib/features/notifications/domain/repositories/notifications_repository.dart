import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

abstract interface class NotificationsRepository {
  FutureBool registerDeviceToken({
    required String deviceToken,
    required String platform,
  });

  FutureBool deleteDeviceToken(String deviceToken);
}
