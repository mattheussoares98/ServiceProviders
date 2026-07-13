import 'dart:typed_data';

import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/services/file_service_platform_helper.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';

/// Implementation of [FileService] delegating to platform-specific helpers
/// to support both Mobile (iOS/Android) and Web platforms.
@LazySingleton(as: FileService)
final class FileServiceImpl implements FileService {
  FileServiceImpl({required ImagePicker imagePicker})
    : _helper = getPlatformHelper(imagePicker);

  final FileServicePlatformHelper _helper;

  @override
  Future<Uint8List> readFileAsBytes(String path) =>
      _helper.readFileAsBytes(path);

  @override
  Future<bool> fileExists(String path) => _helper.fileExists(path);

  @override
  Future<String?> takePhoto() => _helper.takePhoto();

  @override
  Future<String?> recordVideo() => _helper.recordVideo();

  @override
  Future<List<PickedFile>?> pickMediaFromGallery() =>
      _helper.pickMediaFromGallery();

  @override
  Future<List<PickedFile>?> pickDocuments() => _helper.pickDocuments();

  @override
  FutureString compressAndSaveImage(String sourcePath) =>
      _helper.compressAndSaveImage(sourcePath);

  @override
  FutureString compressAndSaveVideo(String sourcePath) =>
      _helper.compressAndSaveVideo(sourcePath);

  @override
  FutureString getOrCreateVideoThumbnail(String videoPath) =>
      _helper.getOrCreateVideoThumbnail(videoPath);

  @override
  FutureString copyFileToSandbox(String sourcePath, String fileName) =>
      _helper.copyFileToSandbox(sourcePath, fileName);

  @override
  Future<int> getFileSizeBytes(String path) => _helper.getFileSizeBytes(path);

  @override
  String getMimeType(String path) => _helper.getMimeType(path);

  @override
  FutureBool deleteLocalFile(String path) => _helper.deleteLocalFile(path);

  @override
  FutureBool openFile(String path) => _helper.openFile(path);

  @override
  Future<String?> resolveSandboxPath(String? localPath) =>
      _helper.resolveSandboxPath(localPath);
}
