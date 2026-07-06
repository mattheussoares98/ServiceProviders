import 'dart:io';

import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

@LazySingleton(as: FileService)
final class FileServiceImpl implements FileService {
  FileServiceImpl({
    required ImagePicker imagePicker,
    required FilePicker filePicker,
  }) : _imagePicker = imagePicker,
       _filePicker = filePicker;

  final ImagePicker _imagePicker;
  final FilePicker _filePicker;

  // Compression constants
  static const _maxCompressedImageBytes = 1 * 1024 * 1024; // 1 MB
  static const _maxCompressedVideoBytes = 50 * 1024 * 1024; // 50 MB
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

  // ──────────────────────────────────────────
  // Picking
  // ──────────────────────────────────────────
  //TODO check this file
  @override
  Future<String?> takePhoto() async {
    final xFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // raw — we compress separately for full control
    );
    return xFile?.path;
  }

  @override
  Future<String?> recordVideo() async {
    final xFile = await _imagePicker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    return xFile?.path;
  }

  @override
  Future<List<String>?> pickMediaFromGallery() async {
    // pickMultipleMedia selects both images and videos from the gallery.
    final xFiles = await _imagePicker.pickMultipleMedia();
    if (xFiles.isEmpty) return null;
    return xFiles.map((f) => f.path).toList();
  }

  @override
  Future<List<String>?> pickDocuments() async {
    final result = await _filePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'xlsx'],
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files
        .where((f) => f.path != null)
        .map((f) => f.path!)
        .toList();
  }

  // ──────────────────────────────────────────
  // Compression
  // ──────────────────────────────────────────

  @override
  FutureString compressAndSaveImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      final sourceSize = await sourceFile.length();

      final ext = p.extension(sourcePath).toLowerCase().replaceFirst('.', '');
      final isAlreadySmall = sourceSize <= _maxCompressedImageBytes;
      final isAlreadyOptimalFormat =
          ext == 'webp' || ext == 'jpeg' || ext == 'jpg';

      // Skip compression only if both conditions are true
      if (isAlreadySmall && isAlreadyOptimalFormat) {
        final destPath = await _sandboxPath('${_uuid()}.$ext');
        await sourceFile.copy(destPath);
        return SuccessState(data: destPath);
      }

      final destPath = await _sandboxPath('${_uuid()}.webp');

      // Attempt 1: quality 80, 1920px
      var result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        destPath,
        quality: 80,
        minHeight: _maxDimensionHigh,
        format: CompressFormat.webp,
      );

      // Attempt 2: quality 65, 1920px
      if (result == null || await result.length() > _maxCompressedImageBytes) {
        result = await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          destPath,
          quality: 65,
          minHeight: _maxDimensionHigh,
          format: CompressFormat.webp,
        );
      }

      // Attempt 3: quality 50, 1280px
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

  // ──────────────────────────────────────────
  // Video compression
  // ──────────────────────────────────────────

  @override
  FutureString compressAndSaveVideo(String sourcePath) async {
    try {
      final destPath = await _sandboxPath('${_uuid()}.mp4');

      // H.264 encoding, CRF 28 (good quality/size ratio), max 720p.
      // scale=-2:720 keeps aspect ratio and ensures height divisible by 2.
      final command =
          '-i "$sourcePath" -c:v libx264 -crf 28 -preset fast '
          '-vf "scale=-2:min(720,ih)" -c:a aac -b:a 128k -movflags +faststart '
          '"$destPath"';

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (!ReturnCode.isSuccess(returnCode)) {
        return FailureState(
          message: 'Não foi possível comprimir o vídeo.'.hardcoded,
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

  // ──────────────────────────────────────────
  // Sandbox copy
  // ──────────────────────────────────────────

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

  // ──────────────────────────────────────────
  // Utilities
  // ──────────────────────────────────────────

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

  // ──────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────

  /// Returns the full path inside the app's documents sandbox directory.
  Future<String> _sandboxPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${dir.path}/attachments');
    if (!attachmentsDir.existsSync()) {
      await attachmentsDir.create(recursive: true);
    }
    return '${attachmentsDir.path}/$fileName';
  }

  /// Generates a simple timestamp-based unique ID for file naming.
  String _uuid() => DateTime.now().microsecondsSinceEpoch.toString();
}
