import 'dart:typed_data';

import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/services/file_service_platform_helper_stub.dart'
    if (dart.library.js_util) 'file_service_platform_helper_web.dart'
    if (dart.library.io) 'file_service_platform_helper_mobile.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

abstract interface class FileServicePlatformHelper {
  Future<Uint8List> readFileAsBytes(String path);
  Future<bool> fileExists(String path);
  Future<String?> takePhoto();
  Future<String?> recordVideo();
  Future<List<PickedFile>?> pickMediaFromGallery();
  Future<List<PickedFile>?> pickDocuments();
  FutureString compressAndSaveImage(String sourcePath);
  FutureString compressAndSaveVideo(String sourcePath);
  FutureString getOrCreateVideoThumbnail(String videoPath);
  FutureString copyFileToSandbox(String sourcePath, String fileName);
  Future<int> getFileSizeBytes(String path);
  String getMimeType(String path);
  FutureBool deleteLocalFile(String path);
  FutureBool openFile(String path);
  Future<String?> resolveSandboxPath(String? localPath);
}

FileServicePlatformHelper getPlatformHelper(ImagePicker imagePicker) =>
    createPlatformHelper(imagePicker);
