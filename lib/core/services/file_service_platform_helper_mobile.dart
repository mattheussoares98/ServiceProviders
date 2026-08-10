import 'dart:io';
import 'dart:typed_data';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/services/file_service_platform_helper.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/platform_util.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

FileServicePlatformHelper createPlatformHelper(
  ImagePicker imagePicker,
  HttpClient client,
) => FileServiceMobile(imagePicker: imagePicker, client: client);

final class FileServiceMobile implements FileServicePlatformHelper {
  FileServiceMobile({
    required ImagePicker imagePicker,
    required HttpClient client,
  }) : _imagePicker = imagePicker,
       _client = client;

  final ImagePicker _imagePicker;
  final HttpClient _client;

  // Compression constants
  static const _maxCompressedImageBytes = 1 * 1024 * 1024; // 1 MB
  static const _maxCompressedVideoBytes = 10 * 1024 * 1024; // 10 MB
  static const _maxDimensionHigh = 1920;
  static const _maxDimensionLow = 1280;

  static const _mimeTypes = <String, String>{
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'heic': 'image/heic',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'pdf': 'application/pdf',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  };

  @override
  Future<Uint8List> readFileAsBytes(String path) => File(path).readAsBytes();

  @override
  Future<bool> fileExists(String path) async => File(path).existsSync();

  @override
  Future<String?> takePhoto() async {
    final xFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (xFile != null) {
      try {
        await Gal.putImage(xFile.path); //! save the file on camera roll
      } catch (_) {}
    }
    return xFile?.path;
  }

  @override
  Future<String?> recordVideo() async {
    final xFile = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 30),
    );
    if (xFile != null) {
      try {
        await Gal.putVideo(xFile.path); //! save the file on camera roll
      } catch (_) {}
    }
    return xFile?.path;
  }

  @override
  Future<List<PickedFile>?> pickMediaFromGallery({bool multiple = true}) async {
    if (multiple) {
      final xFiles = await _imagePicker.pickMultipleMedia();
      if (xFiles.isEmpty) return null;
      return xFiles
          .map((f) => (path: f.path, name: f.name, bytes: null))
          .toList();
    } else {
      final xFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (xFile == null) return null;
      return [(path: xFile.path, name: xFile.name, bytes: null)];
    }
  }

  @override
  Future<List<PickedFile>?> pickDocuments() async {
    final allowedExtensions = PlatformUtil.isMobile
        ? ['pdf', 'docx', 'xlsx']
        : [
            'pdf',
            'docx',
            'xlsx',
            'jpg',
            'jpeg',
            'png',
            'webp',
            'heic',
            'mp4',
            'mov',
          ];
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files
        .where((f) => f.path != null)
        .map((f) => (path: f.path!, name: f.name, bytes: null))
        .toList();
  }

  @override
  FutureString compressAndSaveImage(String sourcePath) async {
    try {
      final ext = p.extension(sourcePath).toLowerCase().replaceFirst('.', '');

      // Image compression is only enabled for mobile devices (Android & iOS).
      if (!PlatformUtil.isMobile) {
        final destPath = await _sandboxPath('${_uuid()}.$ext');
        await File(sourcePath).copy(destPath);
        return SuccessState(data: destPath);
      }

      final sourceFile = File(sourcePath);
      final sourceSize = await sourceFile.length();

      final isAlreadySmall = sourceSize <= _maxCompressedImageBytes;
      final isAlreadyOptimalFormat = ext == 'webp';

      if (isAlreadySmall && isAlreadyOptimalFormat) {
        final destPath = await _sandboxPath('${_uuid()}.$ext');
        await sourceFile.copy(destPath);
        return SuccessState(data: destPath);
      }

      final destPath = await _sandboxPath('${_uuid()}.webp');

      var result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        destPath,
        quality: 80,
        minHeight: _maxDimensionHigh,
        format: CompressFormat.webp,
      );

      if (result == null || await result.length() > _maxCompressedImageBytes) {
        result = await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          destPath,
          quality: 65,
          minHeight: _maxDimensionHigh,
          format: CompressFormat.webp,
        );
      }

      if (result == null || await result.length() > _maxCompressedImageBytes) {
        result = await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          destPath,
          quality: 50,
          minWidth: _maxDimensionLow,
          minHeight: _maxDimensionLow,
          format: CompressFormat.webp,
        );
      }

      if (result == null || await result.length() > _maxCompressedImageBytes) {
        return FailureState(
          message: 'Não foi possível comprimir a imagem. Tente uma foto menor'
              .hardcoded,
        );
      }

      return SuccessState(data: result.path);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  FutureString compressAndSaveVideo(String sourcePath) async {
    try {
      final ext = p.extension(sourcePath).toLowerCase().replaceFirst('.', '');

      // Video compression is only enabled for mobile devices (Android & iOS).
      if (!PlatformUtil.isMobile) {
        final destPath = await _sandboxPath('${_uuid()}.$ext');
        await File(sourcePath).copy(destPath);
        return SuccessState(data: destPath);
      }

      final destPath = await _sandboxPath('${_uuid()}.mp4');

      final command =
          '-y -i $sourcePath -c:v libx264 -crf 28 -preset fast '
          r'-vf scale=-2:min(720\,ih) -c:a aac -b:a 128k -movflags +faststart '
          '$destPath';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        final logs = await session.getAllLogsAsString();
        return FailureState(
          message: 'Não foi possível comprimir o vídeo.'.hardcoded,
          error: logs,
        );
      }

      final outputSize = await File(destPath).length();
      if (outputSize > _maxCompressedVideoBytes) {
        await File(destPath).delete();
        return FailureState(
          message:
              'Vídeo muito grande mesmo após compressão. Grave um vídeo mais curto.'
                  .hardcoded,
        );
      }

      return SuccessState(data: destPath);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  FutureString getOrCreateVideoThumbnail(String videoPath) async {
    try {
      final String cleanName;
      if (videoPath.startsWith('http://') || videoPath.startsWith('https://')) {
        cleanName = videoPath.hashCode.toString();
      } else {
        cleanName = p.basenameWithoutExtension(videoPath);
      }

      final thumbnailPath = await _sandboxPath('thumb_$cleanName.jpg');

      if (File(thumbnailPath).existsSync()) {
        return SuccessState(data: thumbnailPath);
      }

      final command = '-y -ss 0 -i $videoPath -vframes 1 $thumbnailPath';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        final logs = await session.getAllLogsAsString();
        return FailureState(
          message: 'Não foi possível gerar miniatura do vídeo.'.hardcoded,
          error: logs,
        );
      }

      return SuccessState(data: thumbnailPath);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  FutureString copyFileToSandbox(String sourcePath, String fileName) async {
    try {
      final destPath = await _sandboxPath(fileName);
      await File(sourcePath).copy(destPath);
      return SuccessState(data: destPath);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  FutureString downloadUrlToSandbox(String url, String fileName) async {
    try {
      final destPath = await _sandboxPath(fileName);

      // Skip download if already cached.
      if (File(destPath).existsSync()) {
        return SuccessState(data: destPath);
      }

      final response = await _client.download(url, destPath);

      if (response.statusCode != null &&
          (response.statusCode! < 200 || response.statusCode! >= 300)) {
        return FailureState(
          message: 'HTTP ${response.statusCode} ao baixar arquivo.'.hardcoded,
        );
      }

      return SuccessState(data: destPath);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  Future<int> getFileSizeBytes(String path) => File(path).length();

  @override
  String getMimeType(String path) {
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    return _mimeTypes[ext] ?? 'application/octet-stream';
  }

  @override
  FutureBool deleteLocalFile(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
      return const SuccessState(data: true);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  FutureBool openFile(String path) async {
    try {
      final isUri = path.startsWith('http://') || path.startsWith('https://');
      if (isUri) {
        final uri = Uri.parse(path);
        if (await canLaunchUrl(uri)) {
          final success = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (success) {
            return const SuccessState(data: true);
          }
        }
        return FailureState(
          message: 'Não foi possível abrir o link.'.hardcoded,
        );
      } else {
        final file = File(path);
        if (!file.existsSync()) {
          return FailureState(
            message: 'Arquivo local não encontrado.'.hardcoded,
          );
        }
        final result = await OpenFilex.open(path);
        if (result.type == ResultType.done) {
          return const SuccessState(data: true);
        }
        return FailureState(
          message: 'Falha ao abrir arquivo: ${result.message}'.hardcoded,
        );
      }
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  Future<String?> resolveSandboxPath(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return null;
    final fileName = p.basename(localPath);
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/attachments/$fileName';
  }

  Future<String> _sandboxPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${dir.path}/attachments');
    if (!attachmentsDir.existsSync()) {
      await attachmentsDir.create(recursive: true);
    }
    return '${attachmentsDir.path}/$fileName';
  }

  String _uuid() => DateTime.now().microsecondsSinceEpoch.toString();
}
