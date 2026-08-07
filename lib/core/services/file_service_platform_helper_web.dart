import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;
import 'package:o_jogo_da_obra/core/clients/remote/http/http_client.dart';
import 'package:o_jogo_da_obra/core/data/states/data_state.dart';
import 'package:o_jogo_da_obra/core/services/file_service.dart';
import 'package:o_jogo_da_obra/core/services/file_service_platform_helper.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/string_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

FileServicePlatformHelper createPlatformHelper(
  ImagePicker imagePicker,
  HttpClient client,
) => FileServiceWeb(imagePicker: imagePicker, client: client);

final class FileServiceWeb implements FileServicePlatformHelper {
  FileServiceWeb({required ImagePicker imagePicker, required HttpClient client})
    : _imagePicker = imagePicker,
      _client = client;

  final ImagePicker _imagePicker;
  // ignore: unused_field
  final HttpClient _client;

  // In-memory cache to store file bytes on web since there's no native filesystem paths.
  final Map<String, Uint8List> _webCache = {};

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
  Future<Uint8List> readFileAsBytes(String path) async {
    final cached = _webCache[path];
    if (cached != null) return cached;
    throw Exception('File not found in web memory cache: $path');
  }

  @override
  Future<bool> fileExists(String path) async {
    return _webCache.containsKey(path);
  }

  @override
  Future<String?> takePhoto() async {
    // Disabled on Web to restrict camera captures
    return null;
  }

  @override
  Future<String?> recordVideo() async {
    // Disabled on Web to restrict video captures
    return null;
  }

  @override
  Future<List<PickedFile>?> pickMediaFromGallery({bool multiple = true}) async {
    final List<XFile> xFiles;
    if (multiple) {
      xFiles = await _imagePicker.pickMultipleMedia();
    } else {
      final xFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      xFiles = xFile != null ? [xFile] : [];
    }
    if (xFiles.isEmpty) return null;

    final picked = <PickedFile>[];
    for (final file in xFiles) {
      final bytes = await file.readAsBytes();
      // On Web, xFile.path is a blob URL
      _webCache[file.path] = bytes;
      picked.add((path: file.path, name: file.name, bytes: bytes));
    }
    return picked;
  }

  @override
  Future<List<PickedFile>?> pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'xlsx'],
    );
    if (result == null || result.files.isEmpty) return null;

    final picked = <PickedFile>[];
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes != null) {
        // file.path is null on Web. We generate a virtual path key.
        final virtualPath = 'virtual_file://${file.name}';
        _webCache[virtualPath] = bytes;
        picked.add((path: virtualPath, name: file.name, bytes: bytes));
      }
    }
    return picked;
  }

  @override
  FutureString compressAndSaveImage(String sourcePath) async {
    // No-op on Web: preservation of original file
    return SuccessState(data: sourcePath);
  }

  @override
  FutureString compressAndSaveVideo(String sourcePath) async {
    // No-op on Web
    return SuccessState(data: sourcePath);
  }

  @override
  FutureString getOrCreateVideoThumbnail(String videoPath) async {
    // Statically stubbed on Web as FFmpeg is not available
    return const SuccessState(data: '');
  }

  @override
  FutureString copyFileToSandbox(String sourcePath, String fileName) async {
    // Cache the bytes under the new virtual path name if source exists
    final bytes = _webCache[sourcePath];
    if (bytes != null) {
      _webCache[fileName] = bytes;
      return SuccessState(data: fileName);
    }
    return SuccessState(data: sourcePath);
  }

  @override
  FutureString downloadUrlToSandbox(String url, String fileName) async {
    // On Web, files are accessed remotely via remoteUrl or cached virtually.
    return SuccessState(data: fileName);
  }

  @override
  Future<int> getFileSizeBytes(String path) async {
    return _webCache[path]?.length ?? 0;
  }

  @override
  String getMimeType(String path) {
    final ext = _getExtension(path);
    return _mimeTypes[ext] ?? 'application/octet-stream';
  }

  @override
  FutureBool deleteLocalFile(String path) async {
    _webCache.remove(path);
    return const SuccessState(data: true);
  }

  @override
  FutureBool openFile(String path) async {
    try {
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
      return FailureState(message: 'Não foi possível abrir o link.'.hardcoded);
    } catch (error) {
      return FailureState(message: error.toString());
    }
  }

  @override
  Future<String?> resolveSandboxPath(String? localPath) async {
    return localPath;
  }

  String _getExtension(String path) {
    var ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    if (ext.isEmpty) {
      try {
        final uri = Uri.tryParse(path);
        if (uri != null && uri.scheme.isNotEmpty) {
          final filename = uri.path.isNotEmpty
              ? uri.pathSegments.last
              : uri.host;
          ext = p.extension(filename).toLowerCase().replaceFirst('.', '');
        }
      } catch (_) {
        // Fallback if parsing fails due to invalid/custom URI schemes
      }
    }
    return ext;
  }
}
