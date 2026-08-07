import 'package:image_picker/image_picker.dart';
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';
import 'package:o_jogo_da_obra/core/services/file_service_platform_helper.dart';

FileServicePlatformHelper createPlatformHelper(
  ImagePicker imagePicker,
  HttpClient client,
) => throw UnsupportedError(
  'Cannot create FileServicePlatformHelper without platform-specific library',
);
